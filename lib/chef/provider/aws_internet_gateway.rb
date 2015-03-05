require 'chef/provider/aws_provider'

class Chef::Provider::AwsInternetGateway < Chef::Provider::AwsProvider

  action :create do
    unless current_resource
      converge_by("Creating new Internet Gateway #{name} in #{new_driver.aws_config.region}") do
        igw = new_driver.ec2.internet_gateways.create
        igw.tags['Name'] = new_resource.name
        new_resource.internet_gateway_id igw.id
        new_resource.save
      end
    end

    if vpc_id && vpc_id != current_resource.vpc
      converge_by("Attaching Internet Gateway to VPC #{vpc_id}") do
        new_driver.ec2.client.attach_internet_gateway(
          :internet_gateway_id => internet_gateway_id,
          :vpc_id => vpc_id
        )
      end
    end
  end

  action :detach do
    if current_resource && current_resource.vpc
      converge_by("Detaching Internet Gateway #{name} from VPC #{current_resource.vpc}") do
        new_driver.ec2.client.detach_internet_gateway(
          :internet_gateway_id => internet_gateway_id,
          :vpc_id => current_resource.vpc
        )
      end
    end
  end

  action :delete do
    if current_resource
      converge_by("Deleting Internet Gateway #{name}") do
        new_driver.ec2.client.delete_internet_gateway(:internet_gateway_id => internet_gateway_id)
      end
    end
    new_resource.delete
  end

  def load_current_resource
    current_resource = Chef::Resource::AwsInternetGateway.new(new_resource.name, new_resource.run_context)
    return nil unless current_resource && current_resource.internet_gateway_id
    aws_resource = new_driver.ec2.internet_gateways[current_resource.internet_gateway_id]
    return nil unless aws_resource.exists?
    unless aws_resource.attachments.empty?
      current_resource.vpc aws_resource.attachments[0].vpc.id
    end
    @current_resource = current_resource
  end

  # TODO on the update can you specify either vpc_id or vpc_name?

  def vpc_id
    return nil unless new_resource.vpc
    if new_resource.vpc.is_a?(String)
      return new_resource.vpc
    end
    return new_resource.vpc.vpc_id
  end

  def name
    new_resource.name
  end

  def internet_gateway_id
    new_resource.internet_gateway_id
  end

  alias_method :id, :internet_gateway_id

end
