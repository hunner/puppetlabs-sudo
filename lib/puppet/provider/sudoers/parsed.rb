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
# ok, we set record name, but how is this applied to the next line?
      record[:name] = $1
    end
  } 

  text_line :blank, :match => /^\s*$/;

  # ignore for now, I will support this line later
  text_line :defaults, :match => /^Defaults/

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
      if (hash[:line] =~ /^\s*(User_Alias|Runas_Alias|Host_Alias|Cmnd_Alias)\s+(\S+)\s*=\s*(.+)$/)
        hash[:sudo_alias] = $1
        hash[:name] = $2
        hash[:items] = $3
        hash[:items]=hash[:items].gsub(/\s/, '').split(',')
        #puts hash.to_yaml
      elsif (hash[:line] =~ /^(.*)?=(.*)$/)
        # should name already be set when get get here?
        hash = parse_user_spec($1, $2)
      else 
        raise ArgumentError, "unexpected line #{hash[:line]}" 
      end
    }

  def self.parse_user_spec(lhs, rhs) 
    lhs_array = lhs.split(',')  
  end 

  def self.to_line(hash) 
    puts "\nEntering self.to_line for #{hash[:name]}"
    puts hash.to_yaml
    # dynamically call a function based on the value of hash[:type]
    if(hash[:type] == 'alias')
      self.alias_to_line(hash) 
    elsif(hash[:type] == 'spec')
      spec_to_line(hash)
    elsif(hash[:type] == 'default')
      default_to_line(hash)
    end
  end

  def self.spec_to_line(hash)
    "spec"
  end

  def self.alias_to_line(hash) 
    # do I need to ensure that the required elements are here?
    # shouldnt the type do that? check file, its similar
    # since different attributes make sense based on ensure value (dir/file/symlink)
    items=hash[:items]
    items=items.join(',') if items.class == Array
    "#{hash[:sudo_alias]} #{hash[:name]}=#{items}"
  end

  def default_to_line(hash)
    "default"
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
