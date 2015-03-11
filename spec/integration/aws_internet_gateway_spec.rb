require 'spec_helper'
require 'cheffish/rspec/chef_run_support'
require 'aws/core/configuration'

describe Chef::Resource::AwsInternetGateway do
  extend Cheffish::RSpec::ChefRunSupport

  when_the_chef_12_server "exists" do
    organization 'foo'

    let(:ec2_client) { AWS.config.ec2_client }
    let(:entry_store) { Chef::Provisioning::ChefManagedEntryStore.new }

    before :each do
      Chef::Config.chef_server_url = URI.join(Chef::Config.chef_server_url, '/organizations/foo').to_s
    end

    it "should create a new instance" do
      # TODO its dumb that we have to make the client call return our client from here, but
      # if I don't do this AWS somehow keeps making different clients, so I cannot stub them
      expect_any_instance_of(AWS::EC2::InternetGatewayCollection).to receive(:client).and_return(ec2_client)
      resp = ec2_client.stub_for(:create_internet_gateway)
      resp.data[:internet_gateway] = {:internet_gateway_id => 'foo'}

      run_recipe do
        with_driver 'aws::us-west-2'
        aws_internet_gateway 'my_igw'
      end
      expect(chef_run).to have_updated('aws_internet_gateway[my_igw]', :create)
      expect(entry_store.get_data('aws_internet_gateway', 'my_igw')).to eq(
        {"id"=>"my_igw", "reference"=>{"internet_gateway_id"=>"foo"}, "driver_url"=>"aws::us-west-2"}
      )
    end
  end

end
