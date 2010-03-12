Puppet::Type.newtype(:sudoers) do
  @doc = "Manage the contents of /etc/sudoers

there are two types of things here:

  sudoer{'NAME':
    ensure => (absent|present)
    type => (alias|spec) # required??
    alias => (User_alias|Runas_alias|Host_alias|Cmnd_alias),
    items => [] # this is only for aliases
    user_list => []
    host_list => []
    operator_list => []
    # NOPASSWD, PASSWD, NOEXEC, EXEC, SETENV and NOSETENV
    tag_list => []
    command_list => []
  }

  alias NAME - starts with CAP ([A-Z]([A-Z][0-9]_)*)

aliases, user specifications
   User_alias
   Runas_alias
   Host_alias
   Cmnd_alias

alias spec:

 Alias_Type NAME = item1, item2, item3 : NAME = item4, item5


order matters!!


            "
  # we can either remove or add lines
  # they should also be purgable?(whats the namesvar for specs?)
  ensurable

  newparam(:name) do
    desc "Either the name of the alias to create 
          or for user specification, a random string in a comment that serves as a place holder (kind of ugly, but its true)
    "
                              
    isnamevar
  end

#
# this has to be a property to be found by parsedfile, but 
# its really a parameter

  newproperty(:type) do
    desc "Either determines which type of sudo configuration line is
          is being managed. Either user_spec or alias"
  end

  newproperty(:sudo_alias) do
    desc "Types of alias."
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

  newproperty(:users, :array_matching => :all) do
    desc "list of users for user spec"
  end

  newproperty(:hosts, :array_matching => :all) do
    desc "list of hosts for user spec"
  end

  newproperty(:commands, :array_matching => :all) do
    desc "commands to run"
  end

end
 
