provider "aws" {
  shared_credentials_file = "${var.shared_credentials_file}"
  region                  = "${var.region}"
  profile              = "${var.profile}"
}


######################
# mozart
######################

resource "aws_instance" "mozart" {
  ami                    = "${var.mozart["ami"]}"
  instance_type          = "${var.mozart["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.mozart["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  ebs_block_device {
    device_name = "${var.mozart["data_dev"]}"
    volume_size = "${var.mozart["data_dev_size"]}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  connection {
    type     = "ssh"
    user     = "ops"
    private_key = "${file(var.private_key_file)}"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.mozart.private_ip} > mozart_ip_address.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.xfs ${var.mozart["data_dev"]}",
      "sudo bash -c \"echo ${lookup(var.mozart, "data_dev_mount", var.mozart["data_dev"])} ${var.mozart["data"]} auto defaults,nofail,comment=terraform 0 2 >> /etc/fstab\"",
      "sudo mkdir -p ${var.mozart["data"]}",
      "sudo mount ${var.mozart["data"]}",
      "sudo chown -R ops:ops ${var.mozart["data"]}",
      "sudo mkdir -p ${var.mozart["data"]}/var/lib",
      "sudo systemctl stop elasticsearch",
      "sudo systemctl stop redis",
      "sudo systemctl stop rabbitmq-server",
      "sudo mv /var/lib/elasticsearch ${var.mozart["data"]}/var/lib/",
      "sudo ln -sf ${var.mozart["data"]}/var/lib/elasticsearch /var/lib/elasticsearch",
      "sudo mv /var/lib/redis ${var.mozart["data"]}/var/lib/",
      "sudo ln -sf ${var.mozart["data"]}/var/lib/redis /var/lib/redis",
      "sudo mv /var/lib/rabbitmq ${var.mozart["data"]}/var/lib/",
      "sudo ln -sf ${var.mozart["data"]}/var/lib/rabbitmq /var/lib/rabbitmq",
      "sudo systemctl start elasticsearch",
      "sudo systemctl start redis",
      "sudo systemctl start rabbitmq-server"
    ]
  }
}

resource "aws_eip" "mozart" {
  vpc = true 
  instance = "${aws_instance.mozart.id}"
}

output "mozart_pvt_ip" {
  value = "${aws_instance.mozart.private_ip}"
}

output "mozart_pub_ip" {
  value = "${aws_instance.mozart.public_ip}"
}


######################
# metrics
######################

resource "aws_instance" "metrics" {
  ami                    = "${var.metrics["ami"]}"
  instance_type          = "${var.metrics["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.metrics["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  ebs_block_device {
    device_name = "${var.metrics["data_dev"]}"
    volume_size = "${var.metrics["data_dev_size"]}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  connection {
    type     = "ssh"
    user     = "ops"
    private_key = "${file(var.private_key_file)}"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.metrics.private_ip} > metrics_ip_address.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.xfs ${var.metrics["data_dev"]}",
      "sudo bash -c \"echo ${lookup(var.metrics, "data_dev_mount", var.metrics["data_dev"])} ${var.metrics["data"]} auto defaults,nofail,comment=terraform 0 2 >> /etc/fstab\"",
      "sudo mkdir -p ${var.metrics["data"]}",
      "sudo mount ${var.metrics["data"]}",
      "sudo chown -R ops:ops ${var.metrics["data"]}",
      "sudo systemctl stop elasticsearch",
      "sudo systemctl stop redis",
      "sudo mkdir -p ${var.metrics["data"]}/var/lib",
      "sudo mv /var/lib/elasticsearch ${var.metrics["data"]}/var/lib/",
      "sudo ln -sf ${var.metrics["data"]}/var/lib/elasticsearch /var/lib/elasticsearch",
      "sudo mv /var/lib/redis ${var.metrics["data"]}/var/lib/",
      "sudo ln -sf ${var.metrics["data"]}/var/lib/redis /var/lib/redis",
      "sudo systemctl start elasticsearch",
      "sudo systemctl start redis"
    ]
  }
}

resource "aws_eip" "metrics" {
  vpc = true 
  instance = "${aws_instance.metrics.id}"
}

output "metrics_pvt_ip" {
  value = "${aws_instance.metrics.private_ip}"
}

output "metrics_pub_ip" {
  value = "${aws_instance.metrics.public_ip}"
}


######################
# grq
######################

resource "aws_instance" "grq" {
  ami                    = "${var.grq["ami"]}"
  instance_type          = "${var.grq["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.grq["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  ebs_block_device {
    device_name = "${var.grq["data_dev"]}"
    volume_size = "${var.grq["data_dev_size"]}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  connection {
    type     = "ssh"
    user     = "ops"
    private_key = "${file(var.private_key_file)}"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.grq.private_ip} > grq_ip_address.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.xfs ${var.grq["data_dev"]}",
      "sudo bash -c \"echo ${lookup(var.grq, "data_dev_mount", var.grq["data_dev"])} ${var.grq["data"]} auto defaults,nofail,comment=terraform 0 2 >> /etc/fstab\"",
      "sudo mkdir -p ${var.grq["data"]}",
      "sudo mount ${var.grq["data"]}",
      "sudo chown -R ops:ops ${var.grq["data"]}",
      "sudo systemctl stop elasticsearch",
      "sudo systemctl stop redis",
      "sudo mkdir -p ${var.grq["data"]}/var/lib",
      "sudo mv /var/lib/redis ${var.grq["data"]}/var/lib/",
      "sudo ln -sf ${var.grq["data"]}/var/lib/redis /var/lib/redis",
      "sudo systemctl start redis",
      "(sudo mv /var/lib/elasticsearch ${var.grq["data"]}/var/lib/ && sudo ln -sf ${var.grq["data"]}/var/lib/elasticsearch /var/lib/elasticsearch && sudo systemctl start elasticsearch) &"
    ]
  }
}

resource "aws_eip" "grq" {
  vpc = true 
  instance = "${aws_instance.grq.id}"
}

output "grq_pvt_ip" {
  value = "${aws_instance.grq.private_ip}"
}

output "grq_pub_ip" {
  value = "${aws_instance.grq.public_ip}"
}


######################
# factotum
######################

resource "aws_instance" "factotum" {
  ami                    = "${var.factotum["ami"]}"
  instance_type          = "${var.factotum["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.factotum["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  ephemeral_block_device {
    device_name = "${var.ci["docker_storage_dev"]}"
    virtual_name = "ephemeral0"
  }
  ephemeral_block_device {
    device_name = "${var.ci["data_dev"]}"
    virtual_name = "ephemeral1"
  }

  connection {
    type     = "ssh"
    user     = "ops"
    private_key = "${file(var.private_key_file)}"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.factotum.private_ip} > factotum_ip_address.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "git clone https://github.com/pymonger/docker-ephemeral-lvm.git",
      "cd docker-ephemeral-lvm/docker-ephemeral-lvm.d",
      "sudo bash docker-ephemeral-lvm.sh.no_encrypt_data",
      "sudo systemctl stop redis",
      "sudo mkdir -p ${var.factotum["data"]}/var/lib",
      "sudo mv /var/lib/redis ${var.factotum["data"]}/var/lib/",
      "sudo ln -sf ${var.factotum["data"]}/var/lib/redis /var/lib/redis",
      "sudo systemctl start redis",
      "sudo bash -c \"echo ${lookup(var.factotum, "data_dev_mount", var.factotum["data_dev"])} ${var.factotum["data"]} auto defaults,nofail,comment=terraform 0 2 >> /etc/fstab\""
    ]
  }
}

resource "aws_eip" "factotum" {
  vpc = true 
  instance = "${aws_instance.factotum.id}"
}

output "factotum_pvt_ip" {
  value = "${aws_instance.factotum.private_ip}"
}

output "factotum_pub_ip" {
  value = "${aws_instance.factotum.public_ip}"
}


######################
# ci
######################

resource "aws_instance" "ci" {
  ami                    = "${var.ci["ami"]}"
  instance_type          = "${var.ci["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.ci["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  ephemeral_block_device {
    device_name = "${var.ci["docker_storage_dev"]}"
    virtual_name = "ephemeral0"
  }
  ephemeral_block_device {
    device_name = "${var.ci["data_dev"]}"
    virtual_name = "ephemeral1"
  }

  connection {
    type     = "ssh"
    user     = "ops"
    private_key = "${file(var.private_key_file)}"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.ci.private_ip} > ci_ip_address.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "git clone https://github.com/pymonger/docker-ephemeral-lvm.git",
      "cd docker-ephemeral-lvm/docker-ephemeral-lvm.d",
      "sudo bash docker-ephemeral-lvm.sh.no_encrypt_data",
      "sudo bash -c \"echo ${lookup(var.ci, "data_dev_mount", var.ci["data_dev"])} ${var.ci["data"]} auto defaults,nofail,comment=terraform 0 2 >> /etc/fstab\""
    ]
  }
}

resource "aws_eip" "ci" {
  vpc = true 
  instance = "${aws_instance.ci.id}"
}

output "ci_pvt_ip" {
  value = "${aws_instance.ci.private_ip}"
}

output "ci_pub_ip" {
  value = "${aws_instance.ci.public_ip}"
}


######################
# autoscale
######################

resource "aws_instance" "autoscale" {
  ami                    = "${var.autoscale["ami"]}"
  instance_type          = "${var.autoscale["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.autoscale["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  ephemeral_block_device {
    device_name = "${var.ci["docker_storage_dev"]}"
    virtual_name = "ephemeral0"
  }
  ephemeral_block_device {
    device_name = "${var.ci["data_dev"]}"
    virtual_name = "ephemeral1"
  }

  connection {
    type     = "ssh"
    user     = "ops"
    private_key = "${file(var.private_key_file)}"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.autoscale.private_ip} > autoscale_ip_address.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "git clone https://github.com/pymonger/docker-ephemeral-lvm.git",
      "cd docker-ephemeral-lvm/docker-ephemeral-lvm.d",
      "sudo bash docker-ephemeral-lvm.sh.no_encrypt_data",
      "sudo bash -c \"echo ${lookup(var.autoscale, "data_dev_mount", var.autoscale["data_dev"])} ${var.autoscale["data"]} auto defaults,nofail,comment=terraform 0 2 >> /etc/fstab\""
    ]
  }
}

output "autoscale_pvt_ip" {
  value = "${aws_instance.autoscale.private_ip}"
}

output "autoscale_pub_ip" {
  value = "${aws_instance.autoscale.public_ip}"
}
