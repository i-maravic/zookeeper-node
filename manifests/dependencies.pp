class zookeeper_node::dependencies (
) {

  $provider = versioncmp($::puppetversion, '4') ? {
    1       => 'puppet_gem',
    default => 'gem'
  }

  package { 'zookeeper-gem':
    ensure   => 'latest',
    name     => 'zookeeper',
    provider => $provider,
  }

  Package['zookeeper-gem'] -> Zookeeper_node_t <| |>
}
