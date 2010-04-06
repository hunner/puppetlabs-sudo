#
# define that wraps sudoers functionality of sudores
#
define sudo::defaults( $ensure='present', $parameters, $target='/etc/sudoers') {
  sudoers { $name:
    type => 'default',
    ensure => $ensure,
    parameters => $parameters,
    target => $target,
  }
}
