#
# defined resource that wraps the functionality for creating
# aliases with the sudoers type
#   * name - name of alias
#   * type - type of sudo alias can be (Cmnd|Host|User|Runas)(_Alias)?
#   * items - list of things to be aliased.
define sudo::alias( 
  $ensure=present, 
  $sudo_alias,  $items, 
  $comment='',
  $target='/etc/sudoers'
) {
  sudoers { $name:
    type => 'alias',
    ensure => $ensure,
    sudo_alias => $sudo_alias,
    items => $items,
    comment => $comment,
    target => $target,
  }
}
