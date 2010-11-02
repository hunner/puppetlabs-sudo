sudoers { 'BLAH1':
  target => '/tmp/sudoers',
  ensure => present,
  sudo_alias => 'Cmnd_Alias',
  items => ['/usr/bin/which', '/bin/touch'],
  type => 'alias',
}
sudoers { 'BLAH2':
  target => '/tmp/sudoers',
  ensure => present,
  sudo_alias => 'Host_Alias',
  items => ['localhost', 'localhost.localdomain'],
  type => 'alias',
}
sudoers { 'BLAH3':
  target => '/tmp/sudoers',
  ensure => present,
  users => 'dan',
  hosts => 'localhost',
  commands => ['/bin/true', '/bin/false'],
  type => 'user_spec',
}
