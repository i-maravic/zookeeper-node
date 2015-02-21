Puppet::Type.type(:zookeeper_node).provide(:zookeeper_node) do
  require 'zookeeper'

  def zookeeper_err_code_to_str(code)
    case code
      when Zookeeper::ZOK
        'OK'
      when Zookeeper::ZSYSTEMERROR
        'System Error'
      when Zookeeper::ZRUNTIMEINCONSISTENCY
        'Runtime Inconsistency'
      when Zookeeper::ZDATAINCONSISTENCY
        'Data Inconsistency'
      when Zookeeper::ZCONNECTIONLOSS
        'Connection Loss'
      when Zookeeper::ZMARSHALLINGERROR
        'Marshalling Error'
      when Zookeeper::ZUNIMPLEMENTED
        'Unimplemented'
      when Zookeeper::ZOPERATIONTIMEOUT
        'Operation Timeout'
      when Zookeeper::ZBADARGUMENTS
        'Bad Arguments'
      when Zookeeper::ZINVALIDSTATE
        'Invalid State'
      when Zookeeper::ZAPIERROR
        'API Error'
      when Zookeeper::ZNONODE
        'No Node'
      when Zookeeper::ZNOAUTH
        'No Auth'
      when Zookeeper::ZBADVERSION
        'Bad Version'
      when Zookeeper::ZNOCHILDRENFOREPHEMERALS
        'No Children For Ephemerals'
      when Zookeeper::ZNODEEXISTS
        'Node Exists'
      when Zookeeper::ZNOTEMPTY
        'Not Empty'
      when Zookeeper::ZSESSIONEXPIRED
        'Session Expired'
      when Zookeeper::ZINVALIDCALLBACK
        'Invalid Callback'
      when Zookeeper::ZINVALIDACL
        'Invalid ACL'
      when Zookeeper::ZAUTHFAILED
        'Auth Failed'
      when Zookeeper::ZCLOSING
        'Closing'
      when Zookeeper::ZNOTHING
        'Nothing'
      when Zookeeper::ZSESSIONMOVED
        'Session Moved'
      else
        "ErrCode: #{code}"
    end
  end

  def zookeeper_connection(server, port)
    Zookeeper.new(server + ':' + port)
  end

  def zookeeper_exec(server, port, command)
    ret = nil
    begin
      zookeeper = zookeeper_connection(server, port)
      ret = command.call(zookeeper)
    rescue RuntimeError, Zookeeper::Exceptions::ZookeeperException => e
      if e.kind_of? Puppet::Error
        raise e
      else
        raise Puppet::Error, "Caught exception '#{e.message}', " \
                             "while executing zookeeper command " \
                             "on server #{server}:#{port}"
      end
    ensure
      if zookeeper
        zookeeper.close
      end
    end
    ret
  end

  def node_state(server, port, path)
    zookeeper_exec(server,
                   port,
                   lambda { |zookeeper|
                     ret = zookeeper.get(:path => path)
                     unless ret[:rc] == Zookeeper::ZOK or ret[:rc] == Zookeeper::ZNONODE
                       raise Puppet::Error, "Failed to get node from path #{path} " \
                                            "on server #{server}:#{port} " \
                                            "with error '#{zookeeper_err_code_to_str(ret[:rc])}'"
                     end
                     ret
                   })
  end

  def node_create(server, port, path, data)
    zookeeper_exec(server,
                   port,
                   lambda { |zookeeper|
                     ret = zookeeper.create(:path => path, :data => data)
                     unless ret[:rc] == Zookeeper::ZOK
                       raise Puppet::Error, "Failed to create node on path #{path} " \
                                            "on server #{server}:#{port} " \
                                            "with error '#{zookeeper_err_code_to_str(ret[:rc])}'"
                     end
                     ret
                   })
  end

  def node_set(server, port, path, data)
    zookeeper_exec(server,
                   port,
                   lambda { |zookeeper|
                     ret = zookeeper.set(:path => path, :data => data)
                     unless ret[:rc] == Zookeeper::ZOK
                       raise Puppet::Error, "Failed to set data on path #{path} " \
                                            "on server #{server}:#{port} " \
                                            "with error '#{zookeeper_err_code_to_str(ret[:rc])}'"
                     end
                     ret
                   })
  end

  def node_delete(server, port, path)
    zookeeper_exec(server,
                   port,
                   lambda { |zookeeper|
                     ret = zookeeper.delete(:path => path)
                     unless ret[:rc] == Zookeeper::ZOK
                       raise Puppet::Error, "Failed to delete node on path #{path} " \
                                            "on server #{server}:#{port} " \
                                            "with error '#{zookeeper_err_code_to_str(ret[:rc])}'"
                     end
                     ret
                   })
  end

  def create
    node_create(resource[:server],
                resource[:port],
                resource[:path],
                resource[:data] ? resource[:data] : '')
  end

  def destroy
    node_delete(resource[:server],
                resource[:port],
                resource[:path])
  end

  def exists?
    node_state(resource[:server],
               resource[:port],
               resource[:path])[:stat].exists
  end

  def data
    node_state(resource[:server],
               resource[:port],
               resource[:path])[:data]
  end

  def data=(data_value)
    node_set(resource[:server],
             resource[:port],
             resource[:path],
             data_value)
  end
end
