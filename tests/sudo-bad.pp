sudoers{'BLAH':
  #target => '/tmp/sudoers',
  ensure => present,
  sudo_alias => 'Cmnd_Alias',
  items => ['/bin/blah', '/bin/blah4', '/bin/blah2'],
  require => Sudoers['Defaults@host']
}
sudoers{'Defaults@host':
  parameters => ['x=y', 'one=1', 'two=2'],
}
sudoers{'TEST':
  users => 'dan',
  hosts => 'localhost',
  commands => '/bin/true',
}
