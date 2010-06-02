Sudoers{type => 'user_spec'}
resources { 'sudoers':
  purge => true,
}
sudoers{ 'ID1':
  users => 'mike',
  commands => '(ALL) ALL',
  hosts => 'ALL', 
  comment => 'pimp my comment',
  #ensure => absent,
}
sudoers{ 'ID2':
  users => 'dan',
  commands => '(ALL) ALL',
  hosts => 'ALL', 
  comment => 'comment2',
}
sudoers{ 'ID3':
  users => 'bill',
  commands => '(ALL) ALL',
  hosts => 'ALL', 
}
