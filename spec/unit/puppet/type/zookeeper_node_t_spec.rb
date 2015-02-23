require 'spec_helper'

describe Puppet::Type.type(:zookeeper_node_t) do
  before do
    provider_class = stub 'provider class', :name => 'fake', :suitable? => true, :supports_parameter? => true
    provider_class.stubs(:new)

    described_class.stubs(:defaultprovider).returns provider_class
    described_class.stubs(:provider).returns provider_class
  end

  describe 'when validating the attribute' do

    [:path, :server, :port].each do |param|
      it { described_class.attrtype(param).should == :param }
    end

    [:data].each do |property|
      it { described_class.attrtype(property).should == :property }
    end

    it 'use the path parameter as the namevar' do
      described_class.key_attributes.should == [:path]
    end

    describe 'ensure' do
      it 'should be an ensurable value' do
        described_class.propertybyname(:ensure).ancestors.should be_include(Puppet::Property::Ensure)
      end
    end
  end

  describe 'when validating the attribute value' do
    it 'should bootstrap class successfully' do
      ret = described_class.new(:path => '/1/2/3',
                                :server => 'localhost',
                                :port => 2819,
                                :data => 'some_data')

      ret[:ensure].should == :present
      ret[:path].should == '/1/2/3'
      ret[:server].should == 'localhost'
      ret[:port].should == '2819'
      ret[:data].should == 'some_data'
    end

    it 'should use default value 2181 for port' do
      ret = described_class.new(:path => '/1/2/3',
                                :server => 'localhost',
                                :data => 'some_data')

      ret[:path].should == '/1/2/3'
      ret[:server].should == 'localhost'
      ret[:port].should == '2181'
      ret[:data].should == 'some_data'
    end

    it 'should be possible to ensure node to be absent' do
      ret = described_class.new(:ensure => 'absent',
                                :path => '/1/2/3',
                                :server => 'localhost',
                                :data => 'some_data')

      ret[:ensure].should == :absent
      ret[:path].should == '/1/2/3'
      ret[:server].should == 'localhost'
      ret[:port].should == '2181'
      ret[:data].should == 'some_data'
    end

    it 'should autorequire all parent nodes' do
      resource_3_nodes = described_class.new(:path => '/1/2/3',
                                             :server => 'localhost',
                                             :port => 2818,
                                             :data => 'some_data')

      resource_2_nodes = described_class.new(:path => '/1/2',
                                             :server => 'localhost',
                                             :port => 2818,
                                             :data => 'some_data')

      resource_1_node = described_class.new(:path => '/1',
                                            :server => 'localhost',
                                            :port => 2818,
                                            :data => 'some_data')

      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource resource_1_node
      catalog.add_resource resource_3_nodes
      catalog.add_resource resource_2_nodes

      rel = resource_3_nodes.autorequire[0]
      rel.source.ref.should == resource_1_node.ref
      rel.target.ref.should == resource_3_nodes.ref

      rel = resource_3_nodes.autorequire[1]
      rel.source.ref.should == resource_2_nodes.ref
      rel.target.ref.should == resource_3_nodes.ref

      rel = resource_2_nodes.autorequire[0]
      rel.source.ref.should == resource_1_node.ref
      rel.target.ref.should == resource_2_nodes.ref
    end

    it 'should raise error if path is ending with /' do
      expect do
        described_class.new(:path => '/1/',
                            :server => 'localhost',
                            :port => 2818,
                            :data => 'some_data')
      end.to raise_error Puppet::Error
    end

    it 'should raise error if path is not starting with /' do
      expect do
        described_class.new(:path => '1',
                            :server => 'localhost',
                            :port => 2818,
                            :data => 'some_data')
      end.to raise_error Puppet::Error
    end

    it 'should raise error if server is containing :' do
      expect do
        described_class.new(:path => '/1',
                            :server => 'localhost:',
                            :port => 2818,
                            :data => 'some_data')
      end.to raise_error Puppet::Error
    end

    it 'should raise error if port is not number' do
      expect do
        described_class.new(:path => '/1',
                            :server => 'localhost',
                            :port => 'NaN',
                            :data => 'some_data')
      end.to raise_error Puppet::Error
    end
  end

end
