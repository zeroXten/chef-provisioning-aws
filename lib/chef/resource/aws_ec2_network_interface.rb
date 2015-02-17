require 'chef/resource/aws_resource'
require 'chef/provisioning/aws_driver'

class Chef::Resource::AwsEc2NetworkInterface < Chef::Resource::AwsResource
  self.resource_name = 'aws_ec2_network_interface'
  self.databag_name = 'network_interfaces'

  actions :create, :delete, :nothing, :attach, :detach, :associate_address, :dissassociate_address
  default_action :create

  stored_attribute :eni_id
  stored_attribute :created_at

  attribute :name, :kind_of => String, :name_attribute => true
  attribute :description, :kind_of => String, :default => ''
  attribute :subnet_id, :kind_of => String
  attribute :private_ip_address, :kind_of => String, :default => ''
  attribute :security_group_ids, :kind_of => Array
  attribute :instance, :kind_of => String
end
