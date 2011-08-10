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
      elsif record[:line] =~ /#(.*)/
        record[:comment] = $1
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
      parsed = Puppet::Type.type(:sudoers).provider(:parsed)
      if (hash[:line] =~ /^\s*((User|Runas|Host|Cmnd)_Alias)\s+(\S+)\s*=\s*(.+)$/)
        Puppet.debug("parsed line as Alias")
        parsed.parse_alias($1, $3, $4, hash)
      elsif (hash[:line] =~ /^\s*(Defaults\S*)\s*(.*)$/)
        Puppet.debug("parsed line as Defaults")
        parsed.parse_defaults($1, $2, hash)
      elsif (hash[:line] =~ /^\s*(.*?)?=(.*)$/)
        Puppet.debug("parsed line as User Spec")
        parsed.parse_user_spec($1, $2, hash)
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
    raise Puppet::Error, "Invalid alias name, #{name}" unless hash[:name] =~ /[A-Z]([A-Z][0-9]_)*/
    hash[:items] = clean_list(items) 
    hash 
  end

  # parse existing user spec lines from sudoers
  def self.parse_user_spec(users_hosts, commands, hash) 
#puts 'user spec'
    hash[:type] = 'user_spec'
    #hash[:name] = user
    #hash[:hosts] = hosts.gsub(/\s/, '').split(',')
    hash[:commands] = clean_list(commands)
    hash_array = users_hosts.split(',')  
    # every element will be a user until the whitespace delim
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
          raise Puppet::Error, 'found more than one whitespace delim in users_hosts' 
        end
        # sweet we found the delim between user and host
        hash[:users] << user.gsub(/\s/, '')
        hash[:hosts] << host.gsub(/\s/, '')
        # now everything else will be a host
        currentsymbol=:hosts
      elsif element =~ /\s*\S+\s*/
        hash[currentsymbol] << element.gsub(/\s/, '')
      else
        raise Puppet::Error, "Malformed user spec line lhs: #{lhs}"
      end
    end
    if hash[:users].empty? or hash[:hosts].empty?
      raise Puppet::Error, "Malformed user spec line #{hash[:line]}, must specify user and host"
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
  
  #
  # set the record at the specified index as skipped.
  # set 

  def self.skip_comment(records, comment_index)
    if comment_index
      records[comment_index][:skip] = true
    end
  end

  # I could use prefetch_hook to support multi-line entries
  # will use the prefetch_hook to determine if
  # the line before us is a commented namevar line
  # only used for user spec.
  # Most of this code is shameless taken from provider crontab.rb
  # NAMEVAR comments leave me in need of a shower, but it seems to be the only way. I am starting to like them.. is that bad?

  def self.prefetch_hook(records)
    # store comment name vars when we find them
    name,comment,comment_index=nil
    results = records.each_index do |index|
      record = records[index]
      if(record[:record_type] == :comment)
        # if we are a namevar comment
#puts "found a comment: #{record.to_yaml}"
        if record[:name]
#puts "found a comment with :name"
          name = record[:name]
          record[:skip] = true
        elsif record[:comment] != nil
          # get rid of old comment
          skip_comment(records, comment_index)
          comment = record[:comment]
          comment_index = index
        end
      elsif(record[:record_type] == :parsed)
#
# this associates the previous comment with a record.
# I cant think of anyway to get around this.
       # if we are a spec record, check the namevar
        record[:comment] = comment
        skip_comment(records, comment_index)
        comment=nil
        if record[:type] == 'user_spec'
          if name
            #puts "adding to a record"
            record[:name] = name
            name = nil
          else
            fake_namevar = "fake_namevar_#{index}"
            Puppet.warning "user spec #{record[:line]} not created by puppet, adding fake namevar #{fake_namevar}"
            record[:name] = fake_namevar
          end 
        end
      else
        skip_comment(records, comment_index)
      end
    end.reject{|record| record[:skip]}
    results
  end

 # overriding how lines are written to the file
  def self.to_line(hash) 
    #puts "\nEntering self.to_line for #{hash[:name]}"
    #puts "\n#{hash.to_yaml}\n"
#    # dynamically call a function based on the value of hash[:type]
#puts hash[:record_type]
    if(hash[:record_type] == :blank || hash[:record_type] == :comment)
      line = hash[:line]
    elsif(hash[:type] == 'alias')
      line = self.alias_to_line(hash) 
    elsif(hash[:type] == 'user_spec')
      line = self.spec_to_line(hash)
    elsif(hash[:type] == 'default')
      line = self.default_to_line(hash)
    else
      raise Puppet::Error, "dont understand how to write out record \n|#{hash.to_yaml}\n|"
    end
    self.verify_sudo_line(line)
    if hash[:comment]
      line = "##{hash[:comment]}\n#{line}"
    end
    line
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
    Puppet.debug "adding line:  #{str}"
    str
  end

  # write line for alias records
  def self.alias_to_line(hash) 
    # do I need to ensure that the required elements are here?
    # shouldnt the type do that? check file, its similar
    # since different attributes make sense based on ensure value (dir/file/symlink)
    items=self.array_convert(hash[:items])
    str = "#{hash[:sudo_alias]} #{hash[:name]}=#{items}"
    Puppet.debug "adding line: #{str}"
    str
  end

  # write line for default records
  # this is not implemented yet.
  def self.default_to_line(hash)
    parameters=self.array_convert(hash[:parameters])
    str = "#{hash[:name]} #{parameters}"
    Puppet.debug "Adding line #{str}"
    str
  end

  #
  #  this method verifies if a line is valid before its written.
  #  this assumes that we can use visudoers on individual lines
  #
  def self.verify_sudo_line(line)
    # path is currently hardcoded, needs to be fixed
    base = '/tmp/' 
    # find a tmp file that does not exist
    # this should be built into Ruby?
    path = "#{base}.puppettmp_#{rand(10000)}"
    while File.exists?(path) or File.symlink?(path)
      path = "#{base}.puppettmp_#{rand(10000)}"
    end
    File.open(path, "w") { |f| f.print "#{line}\n" }
    begin
      visudo("-cf", path)
    rescue => detail
      raise Puppet::Error, "visudo failed for line: #{line}, #{detail}"
    end
    File.unlink(path) if FileTest.exists?(path)
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

end
