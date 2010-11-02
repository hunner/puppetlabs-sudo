class parent {
  sudo::spec { 'blah4':
    #target => '/tmp/sudoers',
    users => 'dan',
    hosts => 'localhost',
    commands => '/bin/true',
  }
}

class child inherits parent {
  Sudo::Spec['blah4'] {
    users => 'child'
  }
}
include child
