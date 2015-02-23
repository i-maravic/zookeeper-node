class zookeeper_node::dependencies {
  package { 'zookeeper-gem':
    name     => 'zookeeper',
    provider => 'gem',
    ensure   => 'latest',
  }

  Package['zookeeper-gem'] -> Zookeeper_node_t <| |>
}