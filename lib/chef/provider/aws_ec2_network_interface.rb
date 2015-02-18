require 'chef/provider/aws_provider'
require 'date'
require 'retryable'

class Chef::Provider::AwsEc2NetworkInterface < Chef::Provider::AwsProvider
  action :create do
    if existing_eni.nil?
      converge_by("Creating new network interface") do
        @existing_eni = ec2.network_interfaces.create(
          :subnet => new_resource.subnet_id,
          :description => new_resource.description,
          :security_groups => new_resource.security_group_ids
        )

        existing_eni.tags['Name'] = id

        wait_for_eni_status :available

        new_resource.created_at DateTime.now.to_s
        new_resource.eni_id existing_eni.id
      end
    end

    new_resource.save
  end

  action :delete do
    if existing_eni
      converge_by("Deleting network interface #{existing_eni.id}") do
        existing_eni.delete

        wait_for_eni_to_delete
      end
    end

    new_resource.delete
  end

  action :attach do
  end

  action :detach do
  end

  private
  
  def existing_eni
    @existing_eni ||=  new_resource.eni_id == nil ? nil : begin
      Chef::Log.debug("Loading network interface #{new_resource.eni_id}")
      eni = ec2.network_interfaces[new_resource.eni_id]
      if [:deleted, :deleting, :error].include? eni.status
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

  def wait_for_eni_status(status)
    ensure_cb = Proc.new do
      Chef::Log.debug("Waiting for eni status: #{status.to_s}")
    end

    Retryable.retryable(:tries => 30, :sleep => 2, :on => TimeoutError, :ensure => ensure_cb) do
      raise TimeoutError,
        "Timed out waiting for eni status: #{status.to_s}" unless existing_eni.status == status
    end
  end

  def wait_for_eni_to_delete
        Retryable.retryable(:tries => 30, :sleep => 2, :on => TimeoutError) do
      raise TimeoutError,
        "Timed out waiting for eni #{existing_eni.eni_id} to delete" if existing_eni.exists?
    end
  end
end
