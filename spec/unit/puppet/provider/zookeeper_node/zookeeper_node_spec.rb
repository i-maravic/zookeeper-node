require 'puppet'
require 'mocha'

RSpec.configure do |config|
  config.mock_with :mocha
end

provider_class = Puppet::Type.type(:zookeeper_node).provider(:zookeeper_node)
describe provider_class do

  before :each do
    @path = '/unit_test'
    @data = 'test_data'
    @server = 'localhost'
    @port = '2181'

    @resource = Puppet::Type::Zookeeper_node.new(
      {
        :server => @server,
        :port   => @port,
        :path   => @path,
        :data   => @data
      }
    )
    @provider = provider_class.new(@resource)

    @zookeeper_mock = mock

    # We need to always close the Zookeeper connection
    @zookeeper_mock.expects(:close).once

    @provider.expects(:zookeeper_connection)
      .with(@server, @port)
      .returns(@zookeeper_mock)
  end

  describe "GET operation" do

    it 'successfully detects that path exists after successful get request' do
      @zookeeper_mock.expects(:get)
        .with({:path => @path})
        .returns({ :rc   => Zookeeper::ZOK,
                   :stat => stub(:exists => true) })

      @provider.exists?.should == true
    end

    it 'successfully detects that path don\'t exist after successful get request' do
      @zookeeper_mock.expects(:get)
        .with({:path => @path})
        .returns({ :rc   => Zookeeper::ZOK,
                   :stat => stub(:exists => false) })

      @provider.exists?.should == false
    end

    it 'successfully detects that path don\'t exist after get request returns ZNONODE code' do
      @zookeeper_mock.expects(:get)
        .with({:path => @path})
        .returns({ :rc   => Zookeeper::ZNONODE,
                   :stat => stub(:exists => false) })

      @provider.exists?.should == false
    end

    it 'raises Puppet::Error if get receives unexpected rc code' do
      @zookeeper_mock.expects(:get)
        .with({:path => @path})
        .returns({ :rc   => 123456,
                   :stat => stub(:exists => true) })

      expect{ @provider.exists? }.to raise_error(Puppet::Error, /Failed to get node/)
    end

    it 'raises Puppet::Error if Zookeeper raise RuntimeError when calling get' do
      @zookeeper_mock.expects(:get)
        .with({:path => @path})
        .raises(RuntimeError)

      expect{ @provider.exists? }.to raise_error(Puppet::Error, /Caught exception/)
    end

    it 'raises Puppet::Error if Zookeeper raise Zookeeper::Exceptions::ZookeeperException when calling get' do
      @zookeeper_mock.expects(:get)
        .with({:path => @path})
        .raises(Zookeeper::Exceptions::ZookeeperException)

      expect{ @provider.exists? }.to raise_error(Puppet::Error, /Caught exception/)
    end

  end

  describe "CREATE operation" do

    it 'successfully creates path' do
      @zookeeper_mock.expects(:create)
        .with({:path => @path, :data => @data})
        .returns({ :rc   => Zookeeper::ZOK })

      @provider.create.should_not == nil
    end

    it 'raises Puppet::Error if create receives unexpected rc code' do
      @zookeeper_mock.expects(:create)
        .with({:path => @path, :data => @data})
        .returns({ :rc   => Zookeeper::ZNONODE })

      expect{ @provider.create }.to raise_error(Puppet::Error, /Failed to create node/)
    end

    it 'raises Puppet::Error if Zookeeper raise RuntimeError when calling create' do
      @zookeeper_mock.expects(:create)
        .with({:path => @path, :data => @data})
        .raises(RuntimeError)

      expect{ @provider.create }.to raise_error(Puppet::Error, /Caught exception/)
    end

    it 'raises Puppet::Error if Zookeeper raise Zookeeper::Exceptions::ZookeeperException when calling create' do
      @zookeeper_mock.expects(:create)
        .with({:path => @path, :data => @data})
        .raises(Zookeeper::Exceptions::ZookeeperException)

      expect{ @provider.create }.to raise_error(Puppet::Error, /Caught exception/)
    end

  end

  describe "DESTROY operation" do

    it 'successfully delete path' do
      @zookeeper_mock.expects(:delete)
        .with({:path => @path})
        .returns({ :rc   => Zookeeper::ZOK })

      @provider.destroy.should_not == nil
    end

    it 'raises Puppet::Error if delete receives unexpected rc code' do
      @zookeeper_mock.expects(:delete)
        .with({:path => @path})
        .returns({ :rc   => Zookeeper::ZNOTEMPTY })

      expect{ @provider.destroy }.to raise_error(Puppet::Error, /Failed to delete node/)
    end

    it 'raises Puppet::Error if Zookeeper raise RuntimeError when calling delete' do
      @zookeeper_mock.expects(:delete)
        .with({:path => @path})
        .raises(RuntimeError)

      expect{ @provider.destroy }.to raise_error(Puppet::Error, /Caught exception/)
    end

    it 'raises Puppet::Error if Zookeeper raise Zookeeper::Exceptions::ZookeeperException when calling delete' do
      @zookeeper_mock.expects(:delete)
        .with({:path => @path})
        .raises(Zookeeper::Exceptions::ZookeeperException)

      expect{ @provider.destroy }.to raise_error(Puppet::Error, /Caught exception/)
    end

  end

  describe "SET DATA operation" do

    it 'successfully set data on path' do
      new_data = 'new_data'
      @zookeeper_mock.expects(:set)
        .with({:path => @path, :data => new_data})
        .returns({ :rc   => Zookeeper::ZOK })

      ret = @provider.data=(new_data)
      ret.should_not == nil
    end

    it 'raises Puppet::Error if set receives unexpected rc code' do
      new_data = 'new_data'
      @zookeeper_mock.expects(:set)
        .with({:path => @path, :data => new_data})
        .returns({ :rc   => Zookeeper::ZAUTHFAILED })

      expect{ @provider.data=(new_data) }.to raise_error(Puppet::Error, /Failed to set data/)
    end

    it 'raises Puppet::Error if Zookeeper raise RuntimeError when setting data' do
      new_data = 'new_data'
      @zookeeper_mock.expects(:set)
        .with({:path => @path, :data => new_data})
        .raises(RuntimeError)

      expect{ @provider.data=(new_data) }.to raise_error(Puppet::Error, /Caught exception/)
    end

    it 'raises Puppet::Error if Zookeeper raise Zookeeper::Exceptions::ZookeeperException when setting data' do
      new_data = 'new_data'
      @zookeeper_mock.expects(:set)
        .with({:path => @path, :data => new_data})
        .raises(Zookeeper::Exceptions::ZookeeperException)

      expect{ @provider.data=(new_data) }.to raise_error(Puppet::Error, /Caught exception/)
    end

  end

end
