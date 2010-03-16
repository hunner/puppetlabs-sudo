resources{'sudoers':
  purge => true,
}
sudoers{'BLAH1':
  #target => '/tmp/sudoers',
  ensure => present,
  sudo_alias => 'Cmnd_Alias',
  items => ['/bin/blah1', '/bin/blah4', '/bin/blah2'],
  require => Sudoers['BHAH2']
}
sudoers{'blah4':
  #target => '/tmp/sudoers',
  ensure => present,
 users => ['dan', 'dan4', 'dan3'],
  hosts => ['localhost', 'localhost2'],
  commands => ['/bin/true blah', '/bin/false de', '/bin/duder/dude blah'],
  require => Sudoers['Defaults@host'],
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
