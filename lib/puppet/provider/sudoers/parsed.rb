require 'puppet/provider/parsedfile'
sudoers = "/etc/sudoers"

#
# crontab does the same thing, it uses a comment to specify uniqueness
#
 
Puppet::Type.type(:sudoers).provide(
  :parsed, 
  :parent => Puppet::Provider::ParsedFile, 
  :default_target => '/etc/sudoers', 
  :filetype => :flat
) do
 
  desc "The sudoers provider that uses the ParsedFile class"

  commands :visudo => 'visudo'

  # this is just copied from hosts
  text_line :comment, :match => %r{^#}, 
    :post_parse => proc { |record|
    # shameful NAMEVAR hack :(
      if record[:line] =~ /Puppet NAMEVAR (.+)\s*$/
        record[:name] = $1
      end
    } 

  text_line :blank, :match => /^\s*$/;

  #
  # parse lines as either a Defaults, Alias, or User spec.
  #
  # match everything and process entire line
  record_line :parsed, :fields => %w{line},
    :match => /(.*)/,
    :post_parse => proc { |hash|
      Puppet.debug("sudoers post_parse for line #{hash[:line]}")
      # create records for aliases
      if (hash[:line] =~ /^\s*((User|Runas|Host|Cmnd)_Alias)\s+(\S+)\s*=\s*(.+)$/)
        Puppet.debug("parsed line as Alias")
        Puppet::Type.type(:sudoers).provider(:parsed).parse_alias($1, $3, $4, hash)
      elsif (hash[:line] =~ /^\s*(Defaults\S*)\s*(.*)$/)
        Puppet.debug("parsed line as Defaults")
        Puppet::Type.type(:sudoers).provider(:parsed).parse_defaults($1, $2, hash)
      elsif (hash[:line] =~ /^\s*(.*)?=(.*)$/)
        Puppet.debug("parsed line as User Spec")
        Puppet::Type.type(:sudoers).provider(:parsed).parse_user_spec($1, $2, hash)
      else 
        raise Puppet::Error, "invalid line #{hash[:line]}"
      end
#      puts hash.to_yaml
#      hash
    }

  # parse alias lines
  def self.parse_alias(sudo_alias, name, items, hash)
    hash[:type] = 'alias'
    hash[:sudo_alias] = sudo_alias
    hash[:name] = name
    hash[:items] = clean_list(items) 
    hash 
  end

  # parse existing user spec lines from sudoers
  def self.parse_user_spec(users_hosts, commands, hash) 
    hash[:type] = 'user_spec'
    #hash[:name] = user
    #hash[:hosts] = hosts.gsub(/\s/, '').split(',')
    hash[:commands] = clean_list(commands)
    hash_array = users_hosts.split(',')  
    # every element will be a user until the hit the delim
    currentsymbol = :users
    hash[:users] = Array.new
    hash[:hosts] = Array.new
    # parsing users and hosts is kind of complicated, sorry
    hash_array.each do |element|
#puts "!! #{element}"
    # the element that splits users and hosts will be 2 white space delimited strings 
      if element =~ /^\s*(\S+)\s+(\S+)\s*$/
        user, host  = $1, $2
        if currentsymbol == :hosts
          raise Exception, 'found more than one whitespace delim in users_hosts' 
        end
        # sweet we found the delim between user and host
        hash[currentsymbol] << user.gsub(/\s/, '')
        # now everything else will be a host
        currentsymbol=:hosts
        hash[currentsymbol] << host.gsub(/\s/, '')
      elsif element =~ /\s*\S+\s*/
        hash[currentsymbol] << element.gsub(/\s/, '')
      else
        raise Exception, "Malformed user spec line lhs: #{lhs}"
      end
    end
  end 

  # create record for defaults line
  def self.parse_defaults(default, parameters, hash)
    hash[:name] = default
    hash[:type] = 'default'
    hash[:parameters] = parameters.gsub(/\s/, '').split(',')
  end
  
  # can I override this?
  def type=(value)
    raise Puppet::Error, 'not supporting switching NAMEVAR between record types'
  end
  
  # I could use prefetch_hook to support multi-line entries
  # will use the prefetch_hook to determine if
  # the line before us is a commented namevar line
  # only used for user spec.
  # Most of this code is shameless taken from provider crontab.rb
  # NAMEVAR comments leave me in need of a shower, but it seems to be the only way.
  def self.prefetch_hook(records)
    # store comment name vars when we find them
    name=nil
    results = records.each do |record|
      if(record[:record_type] == :comment)
        # if we are a namevar comment
#puts "found a comment: #{record.to_yaml}"
        if record[:name]
#puts "found a comment with :name"
          name = record[:name]
          record[:skip] = true
        end
       # if we are a spec record, check the namevar
      elsif record[:type] == 'user_spec'
        if name
#puts "adding to a record"
          record[:name] = name
          name = nil
        else
          puts "spec record not created by puppet"
          # probably a pre-exting record not created by puppet
        end 
      end
    end.reject{|record| record[:skip]}
    results
  end

 # overriding how lines are written to the file
  def self.to_line(hash) 
    puts "\nEntering self.to_line for #{hash[:name]}"
    puts "\n#{hash.to_yaml}\n"
#    # dynamically call a function based on the value of hash[:type]
    if(hash[:record_type] == :blank || hash[:record_type] == :comment)
      hash[:line]
    elsif(hash[:sudo_alias])
      self.alias_to_line(hash) 
    elsif(hash[:commands])
      self.spec_to_line(hash)
    elsif(hash[:parameters])
      self.default_to_line(hash)
    else
      raise Puppet::Error, "dont understand how to write out record \n|#{hash.to_yaml}\n|"
    end
  end

  # write line for user spec records
  def self.spec_to_line(hash)
#puts hash.to_yaml
    #required
    #users=self.array_convert(hash[:users])
    # required
    hosts=self.array_convert(hash[:hosts])
    users=self.array_convert(hash[:users])
    # required
    commands=self.array_convert(hash[:commands])
    str = "#Puppet NAMEVAR #{hash[:name]}"
    str << "\n#{users} #{hosts}=#{commands}"
    Puppet.notice "adding line:  #{str}"
    str
  end

  # write line for alias records
  def self.alias_to_line(hash) 
    # do I need to ensure that the required elements are here?
    # shouldnt the type do that? check file, its similar
    # since different attributes make sense based on ensure value (dir/file/symlink)
    items=self.array_convert(hash[:items])
    str = "#{hash[:sudo_alias]} #{hash[:name]}=#{items}"
    Puppet.notice "adding line: #{str}"
    str
  end

  # write line for default records
  # this is not implemented yet.
  def self.default_to_line(hash)
    parameters=self.array_convert(hash[:parameters])
    str = "#{hash[:name]} #{parameters}"
    Puppet.notice "Adding line #{str}"
    str
  end

  # convert arrays into to , joined lists
  def self.array_convert(list)
    if list.class == Array
      list.join(',')
    else
      list
    end
  end

  # split a list on delim,  trim leading and trailing white-spaces
  def self.clean_list(list, delim=',')
    list.split(delim).collect do |x| 
      x.gsub(/\s*(.*)?\s*/, '\1')
    end
  end

  # used to verify files with visudo before they are flushed 
  # flush seems to be called more than one time?
  def self.flush_target(target)
    Puppet.info("We are flushing #{target}")
    #  a little pre-flush hot visudo action
    #puts File.read(target)
    visudo("-cf", target) unless (File.zero?(target) or !File.exists?(target))
    super(target)
  end
end
