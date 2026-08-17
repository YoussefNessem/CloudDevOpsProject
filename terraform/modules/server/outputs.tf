output "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  description = "Public IP address of Jenkins"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS name of Jenkins"
  value       = aws_instance.jenkins.public_dns
}

output "jenkins_security_group_id" {
  description = "Jenkins security group ID"
  value       = aws_security_group.jenkins.id
}

output "jenkins_role_arn" {
  description = "IAM Role ARN attached to Jenkins EC2"
  value       = aws_iam_role.jenkins.arn
}
