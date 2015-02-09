require 'chef/resource/aws_resource'
require 'chef/provisioning/aws_driver'

class Chef::Resource::AwsNetworkInterface < Chef::Resource::AwsResource
  self.resource_name = 'aws_network_interface'
  self.databag_name = 'network_interfaces'

  actions :create, :delete, :nothing, :attach, :detach
  default_action :create

  attribute :name, :kind_of => String, :name_attribute => true
  attribute :description, :kind_of => String
  attribute :subnet, :kind_of => String
  attribute :private_ip, :kind_of => String
  attribute :security_groups, :kind_of => Array
  attribute :instance, :kind_of => String
end
