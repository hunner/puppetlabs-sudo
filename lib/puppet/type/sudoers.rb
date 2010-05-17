Puppet::Type.newtype(:sudoers) do
  @doc = "Manage the contents of /etc/sudoers

Author:: Dan Bode (dan@reductivelabs.com)
Copyright:: BLAH!!
License:: GPL3

= Summary

The sudoers type supports managing individual lines from the sudoers file.

Supports present/absent.

supports purging.

= Record Types

There are 3 types of records that are supported:

== Aliases:
 
Manages an alias line of a sudoers file.

Example:
 
sudoers{'ALIAS_NAME':
  ensure => present,
  sudo_alias => 'Cmnd',
  items => ['/bin/true', '/usr/bin/su - bob'],
}

creates the following line:

Cmnd_Alias ALIAS_NAME=/bin/true,/usr/bin/su - bob

== User Specification

sudoers line that specifies how users can run commands.

This there is no way to clearly determine uniqueness, a comment line is added above user spec lines that contains the namevar.

Example:

sudoers{'NAME':
  ensure => present,
  users => ['dan1', 'dan2'],
  hosts => 'ALL',
  commands => [
    '(root) /usr/bin/su - easapp',
    '(easapp)/usr/local/eas-ts/bin/appctl',
  ],
}

creates the following line:  

#Puppet NAMEVAR NAME
dan1,dan2 ALL=(root) /usr/bin/su - easapp,(easapp)/usr/local/eas-ts/bin/appctl

Defaults:

the default name is used to determine uniqueness.

sudoers{'Defaults@host':
  parameters => ['x=y', 'one=1', 'two=2'],
}

Defaults@host x=y,one=1,two=2

== Notes:

- parsing of multi-line sudoers records is not currently supported.
- ordering only applies when records are created.

            "
  # support absent and present (also purge -> true)
  ensurable

  newparam(:name) do
    desc "Either the name of the alias, default, or arbitrary unique string for user specifications"
    isnamevar
    munge do |value|
      #puts "params \n#{resource.original_parameters.to_yaml}\n"
      value
    end
  end


  #
  # I changed this to be required. this will allow me to 
  # do more param checking based on type.
  #
  newparam(:type) do
    desc "optional parameter used to determine what the record type is"
    isrequired
    validate do |type|
      unless type =~ /(default|alias|user_spec)/
        raise Puppet::Exception, "unexpected sudoers type #{type}" 
      end
    end
  end

  newproperty(:sudo_alias) do
    desc "Type of alias. Options are Cmnd, Host, User, and Runas"
    newvalue(/^(Cmnd|Host|User|Runas)(_Alias)?$/)
    # add _Alias if it was ommitted
    munge do |value|
      if(value =~ /^(Cmnd|Host|User|Runas)$/) 
        value << '_Alias'
      end
      value
    end
    # this is now an alias type
  end

  newproperty(:items, :array_matching => :all) do
    desc "list of items applied to an alias"
  end

  newproperty(:target) do
    desc "Location of the shells file"
    defaultto do
      if
        @resource.class.defaultprovider.ancestors.include?(Puppet::Provider::ParsedFile)
        @resource.class.defaultprovider.default_target
      else
        nil
      end
    end
  end

# single user is namevar
  newproperty(:users, :array_matching => :all) do
    desc "list of users for user spec"
    validate do |value|
      if value =~ /^\s*Defaults/
        raise Puppet::Error, 'Cannot specify user named Defaults in sudoers'
      end
    end
  end

  newproperty(:hosts, :array_matching => :all) do
    desc "list of hosts for user spec"
  end

  newproperty(:commands, :array_matching => :all) do
    desc "commands to run"
  end

  newproperty(:parameters, :array_matching => :all) do
    desc "default parameters"
  end

  # I should check that this is not /PUPPET NAMEVAR/ 
  newproperty(:comment) do
    defaultto ''
  end



  # make sure that we only have attributes for either default, alias, or user_spec
  # I need to think about this... This prevents users from being able 
  # to set resource defaults...
  #
  SUDOERS_DEFAULT = [:parameters]
  SUDOERS_ALIAS = [:sudo_alias, :items]
  SUDOERS_SPEC = [:users, :hosts, :commands]
  validate do
    if self[:type] == 'default'
      checkprops(SUDOERS_DEFAULT)      
    elsif self[:type] == 'alias'
      checkprops(SUDOERS_ALIAS)      
    elsif self[:type] == 'user_spec'
      checkprops(SUDOERS_SPEC)      
    else
      # this should not be possible
      raise "Unknown type #{self[:type]}"
    end
  end

  private

    def checkprops(props)
      props.each do |prop|
        unless self[prop.to_symbol]
          raise Puppet::Exception, "missing attribute #{prop} for type #{type}"
        end
      end
    end
#    if self[:sudo_alias] 
#      self[:type] = 'alias'
#      checkprops(SUDOERS_DEFAULT, SUDOERS_SPEC)
#    elsif self[:parameters]
#      self[:type] = 'default'
#      checkprops(SUDOERS_ALIAS, SUDOERS_SPEC)
#    elsif self[:users]
#      self[:type] = 'user_spec'
#      checkprops(SUDOERS_ALIAS, SUDOERS_DEFAULT)
#    else
#      # these are parsed records, do nothing 
#    end
    #puts self.should('sudo_alias')
    #puts self.to_yaml  
    #puts self.eachproperty do |x| puts x end
#  end

#  private

  # check that we dont have any conflicting attributes
#  def checkprops(array_one, array_two)
#    combined = Array.new.concat(array_one).concat(array_two)
#    combined.each do |item|
#      if self[item.to_sym]
#        raise Puppet::Error, "Unexpected attribute #{item} for sudo record type #{self[:type]}"
#      end
#    end 
#  end
end
 
