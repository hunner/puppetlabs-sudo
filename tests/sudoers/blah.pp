#resources { 'sudoers': purge => true }

sudoers{'BLAHDDD':
  # could be a user named defaults
  users =>['dan','bob', 'joe'],
  hosts => 'ALL',
  commands => '/bin/ls -la',
  type => 'user_spec',
  comment => 'my comment'
}
