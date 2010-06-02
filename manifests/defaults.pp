#
# define that wraps sudoers functionality of sudores
#
define sudo::defaults( 
  $ensure='present', 
  $parameters, $target='/etc/sudoers',
  $comment=''
  ) {
  sudoers { $name:
    type => 'default',
    ensure => $ensure,
    parameters => $parameters,
    comment => $comment,
    target => $target,
  }
}
