sudoers{'blah1':
  target => '/tmp/sudoers',
  ensure => absent,
  alias => 'Cmnd_Alias',
  items => ['blah4', 'blah2'],
  linetype => 'alias',
}
#sudoers{'blah2':
#  target => '/tmp/sudoers',
##  ensure => present,
#  alias => 'Host_Alias',
#  items => ['blah2', 'blah3'],
#  type => 'alias',
#}
##sudoers{'blah3':
#  target => '/tmp/sudoers',
##  ensure => present,
#  users => 'dan',
#  hosts => 'localhost',
#  type => 'spec',
#}
