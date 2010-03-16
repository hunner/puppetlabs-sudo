sudoers{'NAME':
  ensure => present,
  users => ['dan1', 'dan2'],
  hosts => 'ALL',
  commands => [
    '(root) /usr/bin/su - easapp',
    '(easapp)/usr/local/eas-ts/bin/appctl',
  ],
}
sudoers{'ALIAS_NAME':
  ensure => present,
  sudo_alias => 'Cmnd',
  items => ['/bin/true', '/usr/bin/su - bob'],
}
sudoers{'Defaults@host':
  parameters => ['x=y', 'one=1', 'two=2'],
 }
