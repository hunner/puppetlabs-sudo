resources { 'sudoers':
  purge => true,
}
sudoers{'fake_namevar_23':
  ensure => present,
  users => ['dan1', 'dan2'],
  hosts => 'ALL',
  commands => [
    '(root) /usr/bin/su - easapp',
    '(easapp)/usr/local/eas-ts/bin/appctl',
  ],
  type => 'user_spec',
}
