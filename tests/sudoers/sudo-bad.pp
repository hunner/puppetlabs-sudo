sudoers{'BLAH':
  #target => '/tmp/sudoers',
  ensure => present,
  sudo_alias => 'Cmnd_Alias',
  items => ['/bin/blah3', '/bin/blah4', '/bin/blah2'],
  require => Sudoers['Defaults@host'],
  type => 'alias',
}
sudoers{'Defaults@host':
  parameters => ['x=z', 'one=1', 'two=2'],
  type => 'default',
}
sudoers{'TEST':
  users => 'dan1',
  hosts => 'localhost',
  commands => '/bin/true',
  type => 'user_spec',
}
