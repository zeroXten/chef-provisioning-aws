require 'chef/provisioning/aws_driver/aws_provider'
require 'chef/resource/aws_vpc'

class Chef::Provider::AwsInternetGateway < Chef::Provisioning::AWSDriver::AWSProvider

  action :create do
    unless aws_object
      converge_by("Creating new Internet Gateway #{name} in #{driver.aws_config.region}") do
        self.aws_object = driver.ec2.internet_gateways.create
        aws_object.tags['Name'] = name

        new_resource.save_managed_entry(aws_object, action_handler)
      end
    end

    if vpc
      if vpc.kind_of?(Chef::Resource::AwsVpc)
        vpc_id = vpc.aws_object.id
      else
        # We could be provided the AWS id or the name of another resource
        begin
          r = new_resource.run_context.resource_collection.find(:aws_vpc => vpc)
          vpc_id = r.aws_object.id
        rescue Chef::Exceptions::ResourceNotFound
          vpc_id = vpc
        end
      end
      if aws_object.vpc.nil? || vpc_id != aws_object.vpc.id
        # We know we need to update the current vpc_id, but we must detach an existing
        # VPC if it is the wrong one
        unless aws_object.attachments.empty?
          converge_by("Detaching Internet Gateway from VPC #{aws_object.vpc.id} before reattaching") do
            driver.ec2.client.detach_internet_gateway(
              :internet_gateway_id => aws_object.id,
              :vpc_id => aws_object.vpc.id
            )
          end
        end
        converge_by("Attaching Internet Gateway to VPC #{vpc_id}") do
          driver.ec2.client.attach_internet_gateway(
            :internet_gateway_id => aws_object.id,
            :vpc_id => vpc_id
          )
        end
      end
    end

  end

  action :detach do
    if aws_object && aws_object.vpc && !(vpc_id=aws_object.vpc.id).nil?
      converge_by("Detaching Internet Gateway from VPC #{vpc_id}") do
        driver.ec2.client.detach_internet_gateway(
          :internet_gateway_id => aws_object.id,
          :vpc_id => vpc_id
        )
      end
    end
  end

  action :delete do
    if aws_object
      converge_by("Deleting Internet Gateway #{name}") do
        aws_object.delete
      end
    end
    new_resource.delete_managed_entry(action_handler)
  end

  def name
    new_resource.name
  end

  def vpc
    new_resource.vpc
  end

  def aws_object
    @aws_object ||= new_resource.aws_object
  end

  attr_writer :aws_object

end
