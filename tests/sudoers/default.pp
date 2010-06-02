#
# this should fail, cannot have a use called Defaults
#
sudoers{'BLAHDDD':
  # could be a user named defaults
  users => ['dan', 'Defaults'],
  hosts => 'ALL',
  commands => '/bin/ls -la'
}
