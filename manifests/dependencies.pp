class zookeeper_node::dependencies {
  package { 'zookeeper-gem':
    ensure   => 'latest',
    name     => 'zookeeper',
    provider => 'gem',
  }

  Package['zookeeper-gem'] -> Zookeeper_node_t <| |>
}