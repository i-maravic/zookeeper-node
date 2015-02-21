
zookeeper_node { '/grandparent':
  server => 'localhost',
  data   => 'biljana',
}

zookeeper_node { '/grandparent/parent':
  ensure => 'present',
  server => 'localhost',
  port   => 2181,
}

zookeeper_node { '/grandparent/parent/child':
  ensure => 'present',
  server => 'localhost',
  data   => 'RandomData'
}

zookeeper_node { '/grandparent/parent/absent_child':
  ensure => 'absent',
  server => 'localhost'
}
