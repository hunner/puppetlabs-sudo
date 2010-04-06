# Defined resoruce to manage sudoers user specification lines.
# 
#  attributes:
#   * name - arbitrary string used to determine uniquemenss
#   * users - list of users
#   * hosts - list of hosts
#   * commands - list of commands
define sudo::spec( 
  $ensure=present, 
  $users, $hosts, $commands, 
  $target='/etc/sudoers'
) {
  sudoers { $name:
    type => 'user_spec',
    ensure => $ensure,
    users => $users,
    hosts => $hosts,
    commands => $commands,
    target => $target,
  }
}
