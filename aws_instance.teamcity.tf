resource "aws_instance" "teamcity" {
  # checkov:skip= CKV2_AWS_17: its bogus
  ami           = var.ami_id
  instance_type = var.instance_type

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = var.volume_delete_on_termination
    encrypted             = var.volume_encrypted
  }

  disable_api_termination = var.disable_api_termination
  disable_api_stop        = var.disable_api_stop
  monitoring              = var.monitoring
  ebs_optimized           = var.ebs_optimized

  key_name               = var.key_pair_name
  subnet_id              = element(var.private_subnets, 0)
  vpc_security_group_ids = [aws_security_group.teamcity.id]
  iam_instance_profile   = aws_iam_instance_profile.teamcity.name

  associate_public_ip_address = var.associate_public_ip_address

  user_data = <<EOF
#! /bin/bash

# Download TeamCity and move to /opt/
sudo yum install git java-21-amazon-corretto.x86_64 -y
curl -L https://download-cdn.jetbrains.com/teamcity/TeamCity-2025.03.tar.gz | tar zx
mv TeamCity /opt/teamcity

# User and group setup
sudo useradd -r -m -s /bin/false teamcity
sudo groupadd teamcity
sudo usermod -aG teamcity teamcity
sudo chown -R teamcity:teamcity /opt/teamcity

cat > /etc/systemd/system/teamcity.service <<SYSTEMDEOF
[Unit]
Description=TeamCity Continuous Integration Server
After=network.target

[Service]
Type=forking
User=teamcity
Group=teamcity
ExecStart=/opt/teamcity/bin/teamcity-server.sh start
ExecStop=/opt/teamcity/bin/teamcity-server.sh stop
PIDFile=/opt/teamcity/logs/teamcity.pid
Restart=on-failure

[Install]
WantedBy=multi-user.target
SYSTEMDEOF

sudo systemctl enable teamcity
sudo systemctl start teamcity

EOF

  lifecycle {
    ignore_changes = [user_data]
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = var.tags
}
