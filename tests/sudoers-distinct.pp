# this will work for all resource types of sudoerd
resources{'sudoers':
  purge => true,
}
sudo::alias{'BLAH1':
  #target => '/tmp/sudo',
  sudo_alias => 'Cmnd_Alias',
  items => ['/bin/blah', '/bin/blah4', '/bin/blah2'],
  require => Sudo::alias['BHAH2']
}
sudo::spec{'blah4':
  #target => '/tmp/sudoers',
  users => 'dan',
  hosts => 'localhost',
  commands => '/bin/true',
}
sudo::alias{'BLAH3':
  sudo_alias => 'Cmnd_Alias',
  items => ['/bin/blah', '/bin/blah4', '/bin/blah2'],
  before => Sudo::alias['BHAH2']
}
sudo::alias{'BHAH2':
  #target => '/tmp/sudoers',
  sudo_alias => 'Host_Alias',
  items => ['blah2', 'blah3', 'blah4', 'blah5'],
  require => Sudo::spec['blah4'],
}
sudo::defaults{'Defaults@host':
  parameters => ['x=y', 'one=1', 'two=2'],
}
