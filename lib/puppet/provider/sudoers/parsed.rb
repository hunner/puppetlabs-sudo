require 'puppet/provider/parsedfile'
sudoers = "/etc/sudoers"

#
# crontab does the same thing, it uses a comment to specify uniqueness
#
 
Puppet::Type.type(:sudoers).provide(
  :parsed, 
  :parent => Puppet::Provider::ParsedFile, 
  :default_target => '/etc/sudoers', 
  # what the heck does this mean?
  :filetype => :flat
) do
 
  desc "The sudoers provider that uses the ParsedFile class"

  commands :visudo => 'visudo'

  # this is just copied from hosts
  text_line :comment, :match => %r{^#}

#, :post_parse => proc { |record|
#    # we determine the name from the comment above user spec lines
#    if record[:line] =~ /Puppet namevar (.+)\s*$/
#      record[:name] = $1
#    end
#  } 

  text_line :blank, :match => /^\s*$/;

  # ignore for now, I will support this line later
#  text_line :defaults, :match => /^Defaults/

# I need to parse the , delim list into an array
# I am pretty sure that I would do this with a block statement

#
# it seems like I have to put type here for it to be accessible to 
# to_line
#


# not bothering to specify match or fields, I will determine all of this
# in post_parse

  # parse everyline not captured as blank or a comment

 # record_line :parsed, :fields => %w{sudo_alias name items}, 
 # :match => /^\s*(User_Alias|Runas_Alias|Host_Alias|Cmnd_Alias)\s+(\S+)\s*=\s*(.+)$/,
  record_line :parsed, :fields => %w{line},
    :match => /(.*)/,
#    # process these lines manually
    :post_parse => proc { |hash|
      puts "\npost_parse"
#      puts hash[:line]
#      # create records for aliases
      if (hash[:line] =~ /^\s*(User_Alias|Runas_Alias|Host_Alias|Cmnd_Alias)\s+(\S+)\s*=\s*(.+)$/)
        Puppet::Type.type(:sudoers).provider(:parsed).parse_alias($1, $2, $3, hash)
#      # create records for user specs
       # we only allow one user to be specified.
      elsif (hash[:line] =~ /^\s*(\S+)(.*)?=(.*)$/)
        Puppet::Type.type(:sudoers).provider(:parsed).parse_user_spec($1, $2, $3, hash)
#      # this is just a place holder, I have not implemted Defaults yet
      elsif (hash[:line] =~ /^\s*(Defaults\S*)\s*(.*)$/)
        Puppet::Type.type(:sudoers).provider(:parsed).parse_defaults($1, $2, hash)
      else 
        raise Exception, "invalid line #{hash[:line]}"
      end
#      puts hash.to_yaml
#      hash
    }

  # parse alias lines
  def self.parse_alias(sudo_alias, name, items, hash)
    hash[:type] = 'alias'
    hash[:sudo_alias] = sudo_alias
    hash[:name] = name
    hash[:items] = items.gsub(/\s/, '').split(',')
    hash 
  end

  # parse existing user spec lines from sudoers
  def self.parse_user_spec(user, hosts, commands, hash) 
    hash[:type] = 'spec'
    hash[:name] = user
    hash[:hosts] = hosts.gsub(/\s/, '').split(',')
    hash[:commands] = commands.gsub(/\s/, '').split(',')
    hash
#    lhs_array = lhs.split(',')  
#    # every element will be a user until the hit the delim
#    currentsymbol = :users
#    hash[:users] = Array.new
#    hash[:hosts] = Array.new
#    # parsing users and hosts is kind of complicated, sorry
#    lhs_array.each do |element|
##puts "!! #{element}"
#    # the element that splits users and hosts will be 2 white space delimited strings 
#      if element =~ /^\s*(\S+)\s+(\S+)\s*$/
#        user, host  = $1, $2
#        raise Exception, 'found more than one whitespace delim when parsing left hand side of user spec' if currentsymbol==:hosts
#        # sweet we found the delim between user and host
#        hash[currentsymbol] << user.gsub(/\s/, '')
#        # now everything else will be a host
#        currentsymbol=:hosts
#        hash[currentsymbol] << host.gsub(/\s/, '')
#      elsif element =~ /\s*\S+\s*/
#        hash[currentsymbol] << element.gsub(/\s/, '')
#      else
#        raise Exception, "Malformed user spec line lhs: #{lhs}"
#      end
#    end
  end 

  def self.parse_defaults(default, parameters, hash)
    hash[:name] = default
    hash[:parameters] = parameters.gsub(/\s/, '').split(',')
  end
  
  # will use the prefetch_hook to determine if
  # the line before us is a commented namevar line
  # only used for user spec.
  # lot of this code is shameless taken from provider crontab.rb
  #

# I could use prefetch_hook to support multoi-line entries

#  def self.prefetch_hook(records)
#    # store comment name vars when we find them
#    name=nil
#    results = records.each do |record|
#      if(record[:record_type] == :comment)
#        # if we are a namevar comment
#puts "found a comment: #{record.to_yaml}"
#        if record[:name]
#puts "found a comment with :name"
#          name = record[:name]
#          record[:skip] = true
#        end
#       # if we are a spec record, check the namevar
#      elsif record[:type] == 'spec'
#        if name
#puts "adding to a record"
#          record[:name] = name
#          name = nil
#        else
#          puts "spec record not created by puppet"
#          # probably a pre-exting record not created by puppet
#        end 
#      end
#    end.reject{|record| record[:skip]}
#    results
#  end

  # overriding how lines are written to the file
  def self.to_line(hash) 
#    puts "\nEntering self.to_line for #{hash[:name]}"
    #puts "\n#{hash.to_yaml}\n"
#    # dynamically call a function based on the value of hash[:type]
    if(hash[:record_type] == :blank || hash[:record_type] == :comment)
#puts "!!!!!!!!#{hash[:line]}"
      hash[:line]
    elsif(hash[:type] == 'alias')
      self.alias_to_line(hash) 
    elsif(hash[:type] == 'spec')
      self.spec_to_line(hash)
    elsif(hash[:type] == 'default')
      self.default_to_line(hash)
#    # parsed records that did not match a declared resource
#    elsif(hash[:line])
#      hash[:line] 
    else
      raise Exception, "dont understand how to write out record #{hash.to_yaml}"
    end
  end

  # write line for user spec records
  def self.spec_to_line(hash)
#puts hash.to_yaml
    #required
    #users=self.array_convert(hash[:users])
    # required
    hosts=self.array_convert(hash[:hosts])
    # required
    commands=self.array_convert(hash[:commands])
    puts "adding line:  #{hash[:name]} #{hosts}=#{commands}"
    "#{hash[:name]} #{hosts}=#{commands}"
  end

  # write line for alias records
  def self.alias_to_line(hash) 
    # do I need to ensure that the required elements are here?
    # shouldnt the type do that? check file, its similar
    # since different attributes make sense based on ensure value (dir/file/symlink)
    items=self.array_convert(hash[:items])
    #puts "adding line: #{hash[:sudo_alias]} #{hash[:name]}=#{items}"
    "#{hash[:sudo_alias]} #{hash[:name]}=#{items}"
  end

  # write line for default records
  # this is not implemented yet.
  def self.default_to_line(hash)
    parameters=self.array_convert(hash[:parameters])
    "#{hash[:name]} #{parameters}"
  end

  # convert arrays into to , joined lists
  def self.array_convert(list)
    if list.class == Array
      list.join(',')
    else
      list
    end
  end

  # used to verify files with visudo before they are flushed 
  def self.flush(record)
  #  a little pre-flush hot visudo action
    super(record)
  end
end
