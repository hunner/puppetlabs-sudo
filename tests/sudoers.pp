resources{'sudoers':
  purge => true,
}
sudoers{'BLAH1':
  #target => '/tmp/sudoers',
  ensure => present,
  sudo_alias => 'Cmnd_Alias',
  items => ['/bin/blah', '/bin/blah4', '/bin/blah2'],
  require => Sudoers['BHAH2']
}
sudoers{'blah4':
  #target => '/tmp/sudoers',
  ensure => present,
  users => 'dan',
  hosts => 'localhost',
  commands => '/bin/true',
}
sudoers{'BHAH2':
  #target => '/tmp/sudoers',
 ensure => present,
  sudo_alias => 'Host_Alias',
  items => ['blah2', 'blah3', 'blah4', 'blah5'],
  require => Sudoers['blah4'],
}
sudoers{'Defaults@host':
  parameters => ['x=y', 'one=1', 'two=2'],
}
