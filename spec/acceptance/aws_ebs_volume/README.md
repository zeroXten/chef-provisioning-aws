Not automated, but was useful as I was making changes  

cd to this directory and run `bundle exec chef-client -z -o aws_ebs_volume_fixture::<recipe>`  
setup and teardown manage the ec2 instance  
or run `spec aws_ebs_volume_spec.rb`

