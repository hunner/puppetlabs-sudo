resources{'sudoers': purge => true}
sudoers{'BLAH':
  #target => '/tmp/sudoers',
  ensure => present,
  sudo_alias => 'Cmnd_Alias',
  items => ['/bin/blah', '/bin/blah4', '/bin/blah2'],
  require => Sudoers['Defaults@host'],
  type => 'alias',
}
sudoers{'Defaults@host':
  parameters => ['x=y', 'one=1', 'two=2'],
  type => 'default',
}
sudoers{'TEST':
  users => 'dan3',
  hosts => 'localhost',
  commands => '/bin/true',
  require => Sudoers['BLAH'],
  type => 'user_spec',
}
