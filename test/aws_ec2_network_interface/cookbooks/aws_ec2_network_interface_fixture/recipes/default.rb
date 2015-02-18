require 'chef/provisioning/aws_driver'
with_driver 'aws'

node.default['test'] = 'eni-test'

aws_key_pair node['test']

with_machine_options :bootstrap_options => { :key_name => node['test'] }

eni1 = aws_ec2_network_interface node['test'] do
  action :nothing
  subnet_id 'subnet-6fab6818'
  security_group_ids ['sg-52a8f837']
end

eni1.run_action(:create)
eni1.run_action(:create)
eni1.run_action(:delete)
eni1.run_action(:delete)
