Puppet::Type.newtype(:sudoers) do
  @doc = "Manage the contents of /etc/sudoers

Author:: Dan Bode (dan@reductivelabs.com)
Copyright:: BLAH!!
License:: GPL3

= Summary

The sudoers type supports managing individual lines from the sudoers file.

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

end
 
