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

  newparam(:name, :namevar => true) do
    desc "Either the name of the alias, default, or arbitrary unique string for user specifications"
    munge do |value|
      value
    end
    # this fails for existing resources, just dont use fake_namevar stuff!
    validate do |name| 
      # please forgive this dirty hack, but only managed lines can 
      # have lines
      if (name =~ /^fake_namevar_\d+/ and resource.line)
        raise Puppet::Error, "cannot use reserved namevar #{name}"
      end
    end
  end


  #
  # I changed this to be required. this will allow me to 
  # do more param checking based on type.
  #
  newproperty(:type) do
    desc "optional parameter used to determine what the record type is"
    # why isnt this working?
    validate do |my_type|
      unless my_type =~ /(default|alias|user_spec)/
        raise Puppet::Error, "unexpected sudoers type #{my_type}" 
      end
    end
    isrequired
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
      if value == 'Defaults'
        raise Puppet::Error, 'Cannot specify user named Defaults in sudoers'
      end
    end
  end

  newproperty(:hosts, :array_matching => :all) do
    desc "list of hosts for user spec"
  end

  # maybe I should do more validation for commands
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
#
# this does not work both ways for some reason
#
#
  validate do
    # this if ensure if a little hackish - 
    # balically, when initialize is called from self.instances
    # none of the attributes are actually set (including type)
    # the best way to tell if I was called by self.instances
    # is to check if ensure has a value?
    if self[:ensure]
      if self.value(:type) == 'default'
        checkprops(SUDOERS_DEFAULT)      
      elsif self.value(:type) == 'alias'
        checkprops(SUDOERS_ALIAS)      
        unless self[:name] =~ /^[A-Z]([A-Z]|[0-9]|_)*$/
          raise Puppet::Error, "alias names #{self[:name]} does not match [A-Z]([A-Z][0-9]_)*"
        end
      elsif self.value(:type) == 'user_spec'
        checkprops(SUDOERS_SPEC)      
      elsif ! self[:type]
        # this is only during purging (self.instances)
        raise Puppet::Error, 'attribute type must be set for sudoers type'
      else
        raise Puppet::Error, "type value #{self[:type]} is not valid"
      end
    else
      # this occurs with self.instances
      # is there a better way?
    end
  end

  private

    def checkprops(props)
      props.each do |prop|
        unless self[prop.to_s]
          raise Puppet::Error, "missing attribute #{prop} for type #{self[:type]}"
        end
      end
    end
end
 
