require 'chef/provider/aws_provider'
require 'date'

class Chef::Provider::AwsEc2NetworkInterface < Chef::Provider::AwsProvider
  action :create do
    if existing_eni.nil?
      converge_by("Creating network interface") do
        @existing_eni = ec2.network_interfaces.create(
          :subnet => new_resource.subnet_id,
          :description => new_resource.description,
          :security_groups => new_resource.security_group_ids
        )

        existing_eni.tags['Name'] = fqn

        new_resource.created_at DateTime.now.to_s
        new_resource.eni_id existing_eni.id
      end
    end

    new_resource.save
  end

  action :delete do
  end

  action :attach do
  end

  action :detach do
  end

  private
  
  def existing_eni
    @existing_eni ||=  new_resource.eni_id == nil ? nil : begin
      Chef::Log.debug("Loading network interface #{new_resource.eni_id}")
      eni = ec2.network_interfaces[new_resource.eni]
      if [:deleted, :deleting, :error].include? volume.status
        nil
      else
        Chef::Log.debug("Found network interface #{eni.inspect}")
        eni
      end
    rescue => e
      Chef::Log.error("Error looking for network interface: #{e}")
      nil
    end
  end

  def id
    new_resource.name
  end
end
