define zookeeper_node (
  $path   = $title,
  $data   = undef,
  $port   = 2181,
  $server = 'localhost',
  $ensure = 'present',
) {
  include zookeeper_node::dependencies

  zookeeper_node_t { $path:
    ensure => $ensure,
    server => $server,
    port   => $port,
    data   => $data,
  }
}