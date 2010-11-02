#sudoers{'BLAH4':
#  sudo_alias => 'Runas_Alias',
#  items => 'root',
#}
sudoers{'BLAH4':
 #target => '/tmp/sudoers',
  ensure => present,
  users => ['dan', 'dan4', 'dan3'],
  hosts => ['localhost', 'localhost2'],
  commands => ['/bin/true blah', '/bin/false de', '/bin/duder/dude blah'],
  type => 'user_spec'
}
