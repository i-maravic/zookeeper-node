class zookeeper_node::dependencies (
  $provider = 'gem',
) {
  package { 'zookeeper-gem':
    ensure   => 'latest',
    name     => 'zookeeper',
    provider => $::zookeeper_node::dependencies::provider,
  }

  Package['zookeeper-gem'] -> Zookeeper_node_t <| |>
}
