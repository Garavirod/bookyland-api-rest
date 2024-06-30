output "ssh_connection_string_for_ec2" {
  value = format("%s%s", "ssh -i /home/ubuntu/keys/aws_ec2_terraform ubuntu@", aws_instance.dev_bookyland_ec2.public_ip)
}

output "dev_bookyland_ec2_instance_id" {
  value = aws_instance.dev_bookyland_ec2.id
}