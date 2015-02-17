require 'spec_helper'
require 'chef_zero_rspec_helper'
#AWS.stub!

describe Chef::Provider::AwsEc2NetworkInterface do
  extend ChefZeroRspecHelper
  let(:new_resource) { 
    Chef::Resource::AwsEc2NetworkInterface.new('new_eni', run_context)
  }

  let(:my_node) {
    node = Chef::Node.new
    node.automatic['platform'] = 'ubuntu'
    node.automatic['platform_version'] = '12.04'
    node
  }
  
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  
  let(:run_context) {
    cookbook_collection = {}
    Chef::RunContext.new(my_node, cookbook_collection ,events)
  }
  
  subject(:provider) {
    described_class.new(new_resource, run_context)
  }

  when_the_chef_server 'is empty' do
    describe '#action_create' do
      it 'should converge' do
        new_resource.subnet_id('subnet-6fab6818')
        new_resource.security_group_ids(['sg-52a8f837'])
        expect(new_resource).to receive(:save)
        provider.action_create
      end
    end
  end
end
