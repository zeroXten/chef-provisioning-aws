require 'chef/provisioning/aws_driver'

with_driver 'aws::eu-west-1'

aws_vpc 'test-vpc' do
  cidr_block '10.0.0.0/24'
  internet_gateway true
end

aws_route_table 'ref-public1' do
  vpc 'test-vpc'
  routes '0.0.0.0/0' => :internet_gateway
end

aws_key_pair 'ref-key-pair'

m = machine 'test' do
  machine_options bootstrap_options: { key_name: 'ref-key-pair' }
end

# TODO this still fails
aws_route_table 'ref-public2' do
  vpc 'test-vpc'
  routes '0.0.0.0/0' => :internet_gateway,
         '0.0.0.1/0' => m
end
