require 'chef/provisioning/aws_driver/aws_resource_with_entry'

class Chef::Resource::AwsInternetGateway < Chef::Provisioning::AWSDriver::AWSResourceWithEntry
  aws_sdk_type AWS::EC2::InternetGateway,
               managed_entry_type: :aws_internet_gateway,
               managed_entry_id_name: 'internet_gateway_id'

  actions :create, :delete, :detach, :nothing
  default_action :create

  attribute :name, kind_of: String, name_attribute: true
  attribute :vpc, kind_of: [String, Chef::Resource::AwsVpc]

  attribute :internet_gateway_id, kind_of: String, aws_id_attribute: true, lazy_default: proc {
    name =~ /^igw-[a-f0-9]{8}$/ ? name : nil
  }

  def aws_object
    driver, id = get_driver_and_id
    result = driver.ec2.internet_gateways[id] if id
    result && result.exists? ? result : nil
  end

end
