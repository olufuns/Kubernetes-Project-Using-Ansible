# Create Ansible Server
resource "aws_instance" "ansible-server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = var.security_groups
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  user_data                   = templatefile("./module/ansible/user-data.sh", {
    keypair     = var.priv-key,
    haproxy1    = var.HAproxy1-IP,
    haproxy2    = var.HAproxy2-IP,
    m1          = var.master1-IP,
    m2          = var.master2-IP,
    m3          = var.master3-IP,
    w1          = var.worker1-IP,
    w2          = var.worker2-IP,
    w3          = var.worker3-IP
  })
 
  tags = {
    name = var.tag-ansible-server
  }
}

#Create null resource to copy playbooks directory into ansible server
resource "null_resource" "copy-playbooks" {
  connection {
    type = "ssh"
    host = aws_instance.ansible-server.private_ip
    user = "ubuntu"
    private_key = var.priv-key
    bastion_host = var.bastion_host
    bastion_user = "ubuntu"
    bastion_private_key = var.priv-key
  }
  provisioner "file" {
    source = "./module/ansible/playbooks"
    destination = "/home/ubuntu/playbooks"
  }
}