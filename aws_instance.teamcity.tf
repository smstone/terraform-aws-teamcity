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


# Default Server Config
cat > /opt/teamcity/conf/server.xml <<SERVERCONFEOF
<?xml version='1.0' encoding='utf-8'?>
<Server port="8105" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
  <GlobalNamingResources>
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
  </GlobalNamingResources>
  <Service name="Catalina">
    <Connector port="8111" protocol="org.apache.coyote.http11.Http11NioProtocol"
               connectionTimeout="60000"
               redirectPort="8543"
               useBodyEncodingForURI="true"
               tcpNoDelay="1"
         maxHttpHeaderSize="16000"
         proxyName="${var.server_fqdn}"
         proxyPort="443"
         scheme="https"
         secure="true"
    />
    <Engine name="Catalina" defaultHost="localhost">
      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
               resourceName="UserDatabase"/>
      </Realm>

      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">

        <Valve className="org.apache.catalina.valves.ErrorReportValve"
               showReport="false"
               showServerInfo="false" />
      </Host>
    </Engine>
  </Service>
</Server>
SERVERCONFEOF

# SystemD file
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
