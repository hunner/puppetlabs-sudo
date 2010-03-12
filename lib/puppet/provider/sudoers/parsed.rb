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
  text_line :comment, :match => %r{^#}, :post_parse => proc { |record|
    # we determine the name from the comment above user spec lines
    if record[:line] =~ /Puppet Name: (.+)\s*$/
## ok, we set record name, but how is this applied to the next line?
      record[:name] = $1
    end
  } 

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

# parse everything else?
  record_line :parsed, :fields => %w{line},
    :match => /(.*)/,
    :post_parse => proc { |hash|
      puts "\npost_parse"
      puts hash[:line]
      # create records for aliases
      if (hash[:line] =~ /^\s*(User_Alias|Runas_Alias|Host_Alias|Cmnd_Alias)\s+(\S+)\s*=\s*(.+)$/)
        hash[:type] = 'alias'
        hash[:sudo_alias] = $1
        hash[:name] = $2
        hash[:items] = $3.gsub(/\s/, '').split(',')
        #puts hash.to_yaml
      # create records for user specs
      elsif (hash[:line] =~ /^(.*)?=(.*)$/)
        #hash = Puppet::Provider::Sudoers::Parsed.parse_user_spec($1, $2)
puts hash[:line]
        # should name already be set when get get here?
        lhs = $1
        rhs = $2
        hash[:type] = 'spec'
        hash[:commands] = rhs.gsub(/\s/, '').split(',')
        lhs_array = lhs.split(',')  
        # every element will be a user until the hit the delim
        currentsymbol = :users
        hash[:users] = Array.new
        hash[:hosts] = Array.new
        lhs_array.each do |element|
puts "!! #{element}"
        # all elements will be a single string, except the one that splits users and hosts
          if element =~ /^\s*(\S+)\s+(\S+)\s*$/
            user, host  = $1, $2
            raise Exception, 'found more than one whitespace delin when parsing left hand side of user spec' if currentsymbol==:hosts
            # sweet we found the delim between user and host
            hash[currentsymbol] << user.gsub(/\s/, '')
            # now everything else will be a host
            currentsymbol=:hosts
            hash[currentsymbol] << host.gsub(/\s/, '')
          elsif element =~ /\s*\S+\s*/
            hash[currentsymbol] << element.gsub(/\s/, '')
          else 
            raise ArgumentError, "unexpected line #{hash[:line]}" 
          end
        end
      end
      puts hash.to_yaml
    }

#  def self.parse_user_spec(lhs, rhs) 
#puts hash[:line]
#    # should name already be set when get get here?
#    #lhs = $1
#    #rhs = $2
#    hash[:type] = 'spec'
#    hash[:commands] = rhs.gsub(/\s/, '').split(',')
#    lhs_array = lhs.split(',')  
#    # every element will be a user until the hit the delim
#    currentsymbol = :users
#    hash[:users] = Array.new
#    hash[:hosts] = Array.new
#    lhs_array.each do |element|
#puts "!! #{element}"
#    # all elements will be a single string, except the one that splits users and hosts
#    if element =~ /^\s*(\S+)\s+(\S+)\s*$/
#      user, host  = $1, $2
#      raise Exception, 'found more than one whitespace delin when parsing left hand side of user spec' if currentsymbol==:hosts
#      # sweet we found the delim between user and host
#      hash[currentsymbol] << user.gsub(/\s/, '')
#      # now everything else will be a host
#      currentsymbol=:hosts
#      hash[currentsymbol] << host.gsub(/\s/, '')
#    elsif element =~ /\s*\S+\s*/
#      hash[currentsymbol] << element.gsub(/\s/, '')
#    end
#    puts hash.to_yaml
#  end
#    hash[:type] = 'spec'
#    hash[:commands] = rhs.gsub(/\s/, '').split(',')
#    lhs_array = lhs.split(',')  
#    # every element will be a user until the hit the delim
#    currentsymbol = :users
#    lhs_array do |element|
#      # all elements will be a single string, except the one that splits users and hosts
#      if element =~ /(\S+)\s*(\S+)/
#        # sweet we found the delim between user and host
#        hash[currentsymbol]=element
#        # now everything else will be a host
#        currentsymbol=:hosts
#        hash[currentsymbol]=element
#      else
#        hash[currentsymbol]=element
#      end
#    end
#  end 

  def self.prefetch_hook(records)
puts "HERE!!!"
    records
  end

  def self.to_line(hash) 
    puts "\nEntering self.to_line for #{hash[:name]}"
    #puts hash.to_yaml
    # dynamically call a function based on the value of hash[:type]
    if(hash[:type] == 'alias')
      self.alias_to_line(hash) 
    elsif(hash[:type] == 'spec')
      self.spec_to_line(hash)
    elsif(hash[:type] == 'default')
      default_to_line(hash)
    end
  end

  def self.spec_to_line(hash)
puts hash.to_yaml
    #required
    users=self.array_convert(hash[:users])
    # required
    hosts=self.array_convert(hash[:hosts])
    # required
    commands=self.array_convert(hash[:commands])
    puts "adding line:  #{users} #{hosts}=#{commands}"
    "#{users} #{hosts}=#{commands}"
  end

  def self.alias_to_line(hash) 
    # do I need to ensure that the required elements are here?
    # shouldnt the type do that? check file, its similar
    # since different attributes make sense based on ensure value (dir/file/symlink)
    items=self.array_convert(hash[:items])
    #puts "adding line: #{hash[:sudo_alias]} #{hash[:name]}=#{items}"
    "#{hash[:sudo_alias]} #{hash[:name]}=#{items}"
  end

  def self.default_to_line(hash)
    users=hash[:users]
    # optional?
    hosts=hash[:hosts]
  end

  def self.array_convert(list)
    if list.class == Array
      list.join(',')
    else
      list
    end
  end

  def self.flush(record)
#  a little pre-flush host visudo action
#
    super(record)
  end

# lets assume that runas is always there and lets not deal with options yet
#  record_line :spec, :fields => %w{users hosts runas specs type},
#    :match => %r{(\S+)\s+(\S+)=(\(\S+\))\s+(.+)},
#    :post_parse => proc { |hash|
#      puts 'spec'
#    } 

# I dont know if I can properly support multiple commands
# because they are composite, one command, one runas, multiple tags
#  record_line :spec, :fields => %w{user host runas tags commands name},
#    :match => %r{^\s*(\S+)\s+(\S+)\s*=\s*(\(\S+\))?(.+)$},
#    :optional => %w{runas tags}

# I need to override flush to validate sudoers
#
#
#
end
