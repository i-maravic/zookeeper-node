Puppet::Type.newtype(:zookeeper_node_t) do
  desc 'Manage nodes on zookeeper server.'

  ensurable

  newparam(:path, :namevar => true) do
    desc 'Path to manage on Zookeeper cluster. Needs to be absolute path. Must not end with /.'
    validate do |value|
      raise ArgumentError, 'You have to use absolute paths!' unless Puppet::Util.absolute_path? value
      raise ArgumentError, 'Path must not end with \'/\'' if value[-1, 1] == '/'
    end
  end

  newproperty(:data) do
    desc 'Data to be stored on path on Zookeeper cluster.'
  end

  newparam(:server) do
    desc 'Zookeeper server to connect to. Defaults to localhost.'
    defaultto 'localhost'
    validate do |value|
      raise ArgumentError, 'Server can\'t contain ":"' if value.include? ':'
    end
  end

  newparam(:port) do
    desc 'Zookeeper port to connect to. Defaults to 2181.'
    defaultto 2181
    newvalues(/^\d+$/)
    munge do |value|
      value.to_s
    end
  end

  autorequire(:zookeeper_node_t) do
    names = @parameters[:path].value.split('/')
    names.slice(1..-2).inject([]) { |a,v| a << "#{a.last}/#{v}" }.collect { |fs| names[0] + fs }
  end
end
