sudoers{'blah1':
  #target => '/tmp/sudoers',
  ensure => present,
  sudo_alias => 'Cmnd_Alias',
  items => ['blah4', 'blah2'],
  type => 'alias',
}
sudoers{'blah2':
  #target => '/tmp/sudoers',
 ensure => present,
  sudo_alias => 'Host_Alias',
  items => ['blah2', 'blah3', 'blah4'],
  type => 'alias',
  require => Sudoers['blah3'],
}
sudoers{'blah3':
  #target => '/tmp/sudoers',
  ensure => present,
  #users => ['dan', 'dan2', 'dan3'],
  hosts => ['localhost', 'localhost2'],
  commands => ['true', 'false', 'dude'],
  type => 'spec',
}
sudoers{'Defaults@host':
  type => 'default',
  parameters => ['x=y', 'one=1', 'two=2'],
}
