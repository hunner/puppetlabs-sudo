# invalid line should break and not be written to /etc/sudoers
Sudoers{type => 'alias'}
sudoers{'blah4':
  sudo_alias => 'Runas_Alias',
  items => 'root',
  commands => '/bin/true'
}
