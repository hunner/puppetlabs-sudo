sudoers{'NAME':
  ensure => present,
  users => ['dan1', 'dan2'],
  hosts => 'ALL',
  commands => [
    '(root) /usr/bin/su - easapp',
    '(easapp)/usr/local/eas-ts/bin/appctl',
  ],
  type => 'user_spec',
  target => '/tmp/sudoers.test',
}
sudoers{'ALIAS_NAME':
  ensure => present,
  sudo_alias => 'Cmnd',
  items => ['/bin/true', '/usr/bin/su - bob'],
  type => 'alias',
  target => '/tmp/sudoers.test',
}
sudoers{'Defaults@host':
  parameters => ['x=y', 'one=1', 'two=2'],
  type => 'default',
  target => '/tmp/sudoers.test',
}
