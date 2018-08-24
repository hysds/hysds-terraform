provider "aws" {
  shared_credentials_file = "${var.shared_credentials_file}"
  region                  = "${var.region}"
  profile                 = "${var.profile}"
}


######################
# mozart
######################

resource "aws_instance" "mozart" {
  ami                    = "${var.ami}"
  instance_type          = "${var.mozart["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.mozart["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  root_block_device {
    volume_type = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "${var.mozart["docker_storage_dev"]}"
    volume_size = "${var.mozart["docker_storage_dev_size"]}"
    volume_type = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "${var.mozart["data_dev"]}"
    volume_size = "${var.mozart["data_dev_size"]}"
    volume_type = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "${var.mozart["persist_dev"]}"
    volume_size = "${var.mozart["persist_dev_size"]}"
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

  provisioner "file" {
    source      = "${var.private_key_file}"
    destination = ".ssh/${basename(var.private_key_file)}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/${basename(var.private_key_file)}",
      "sudo yum install -y awscli",
      "sudo mkfs.xfs ${var.mozart["persist_dev"]}",
      "sudo bash -c \"echo ${lookup(var.mozart, "persist_dev_mount", var.mozart["persist_dev"])} ${var.mozart["persist"]} auto defaults,nofail,comment=terraform 0 2 >> /etc/fstab\"",
      "sudo mkdir -p ${var.mozart["persist"]}",
      "sudo mount ${var.mozart["persist"]}",
      "sudo chown -R ops:ops ${var.mozart["persist"]}",
      "sudo mkdir -p ${var.mozart["persist"]}/var/lib",
      "mkdir -p ~/.aws",
      "chmod 700 ~/.aws",
      "bash -c \"echo [default] > ~/.aws/credentials\"",
      "bash -c \"echo aws_access_key_id = ${var.access_key} >> ~/.aws/credentials\"",
      "bash -c \"echo aws_secret_access_key = ${var.secret_key} >> ~/.aws/credentials\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/credentials\"",
      "chmod 600 ~/.aws/credentials",
      "bash -c \"echo [default] > ~/.aws/config\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/config\"",
      "chmod 600 ~/.aws/config",
      "virtualenv --system-site-packages ~/mozart",
      "source ~/mozart/bin/activate",
      "pip install -U pip",
      "pip install -U setuptools",
      "mkdir -p ~/mozart/etc",
      "mkdir -p ~/mozart/log",
      "mkdir -p ~/mozart/run",
      "mkdir -p ~/mozart/ops",
      "bash -c \"echo >> ~/.bash_profile\"",
      "bash -c \"echo '# source virtualenv' >> ~/.bash_profile\"",
      "bash -c \"echo export MOZART_DIR=$HOME/mozart >> ~/.bash_profile\"",
      "bash -c \"echo source $MOZART_DIR/bin/activate >> ~/.bash_profile\""
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "bash -c \"echo export MOZART_PVT_IP=${aws_instance.mozart.private_ip} > cluster_env.sh\"",
      "bash -c \"echo export MOZART_PUB_IP=${aws_instance.mozart.public_ip} >> cluster_env.sh\"",
      "bash -c \"echo export MOZART_RABBIT_PVT_IP=${aws_instance.mozart.private_ip} >> cluster_env.sh\"",
      "bash -c \"echo export MOZART_RABBIT_PUB_IP=${aws_instance.mozart.public_ip} >> cluster_env.sh\"",
      "bash -c \"echo export MOZART_REDIS_PVT_IP=${aws_instance.mozart.private_ip} >> cluster_env.sh\"",
      "bash -c \"echo export MOZART_REDIS_PUB_IP=${aws_instance.mozart.public_ip} >> cluster_env.sh\"",
      "bash -c \"echo export MOZART_ES_PVT_IP=${aws_instance.mozart.private_ip} >> cluster_env.sh\"",
      "bash -c \"echo export MOZART_ES_PUB_IP=${aws_instance.mozart.public_ip} >> cluster_env.sh\"",
      "bash -c \"echo export METRICS_PVT_IP=${aws_instance.metrics.private_ip} >> cluster_env.sh\"",
      "bash -c \"echo export METRICS_PUB_IP=${aws_instance.metrics.public_ip} >> cluster_env.sh\"",
      "bash -c \"echo export METRICS_REDIS_PVT_IP=${aws_instance.metrics.private_ip} >> cluster_env.sh\"",
      "bash -c \"echo export METRICS_REDIS_PUB_IP=${aws_instance.metrics.public_ip} >> cluster_env.sh\"",
      "bash -c \"echo export METRICS_ES_PVT_IP=${aws_instance.metrics.private_ip} >> cluster_env.sh\"",
      "bash -c \"echo export METRICS_ES_PUB_IP=${aws_instance.metrics.public_ip} >> cluster_env.sh\"",
      "bash -c \"echo export GRQ_PVT_IP=${aws_instance.grq.private_ip} >> cluster_env.sh\"",
      "bash -c \"echo export GRQ_PUB_IP=${aws_instance.grq.public_ip} >> cluster_env.sh\"",
      "bash -c \"echo export GRQ_ES_PVT_IP=${aws_instance.grq.private_ip} >> cluster_env.sh\"",
      "bash -c \"echo export GRQ_ES_PUB_IP=${aws_instance.grq.public_ip} >> cluster_env.sh\"",
      "bash -c \"echo export FACTOTUM_PVT_IP=${aws_instance.factotum.private_ip} >> cluster_env.sh\"",
      "bash -c \"echo export FACTOTUM_PUB_IP=${aws_instance.factotum.public_ip} >> cluster_env.sh\"",
      "bash -c \"echo export CI_PVT_IP=${aws_instance.ci.private_ip} >> cluster_env.sh\"",
      "bash -c \"echo export CI_PUB_IP=${aws_instance.ci.public_ip} >> cluster_env.sh\"",
      "bash -c \"echo export VERDI_PVT_IP=${aws_instance.ci.private_ip} >> cluster_env.sh\"",
      "bash -c \"echo export VERDI_PUB_IP=${aws_instance.ci.public_ip} >> cluster_env.sh\""
    ]
  }
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
  ami                    = "${var.ami}"
  instance_type          = "${var.metrics["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.metrics["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  root_block_device {
    volume_type = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "${var.metrics["docker_storage_dev"]}"
    volume_size = "${var.metrics["docker_storage_dev_size"]}"
    volume_type = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "${var.metrics["data_dev"]}"
    volume_size = "${var.metrics["data_dev_size"]}"
    volume_type = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "${var.metrics["persist_dev"]}"
    volume_size = "${var.metrics["persist_dev_size"]}"
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
      "sudo yum install -y awscli",
      "sudo mkfs.xfs ${var.metrics["persist_dev"]}",
      "sudo bash -c \"echo ${lookup(var.metrics, "persist_dev_mount", var.metrics["persist_dev"])} ${var.metrics["persist"]} auto defaults,nofail,comment=terraform 0 2 >> /etc/fstab\"",
      "sudo mkdir -p ${var.metrics["persist"]}",
      "sudo mount ${var.metrics["persist"]}",
      "sudo chown -R ops:ops ${var.metrics["persist"]}",
      "sudo mkdir -p ${var.metrics["persist"]}/var/lib",
      "mkdir -p ~/.aws",
      "chmod 700 ~/.aws",
      "bash -c \"echo [default] > ~/.aws/credentials\"",
      "bash -c \"echo aws_access_key_id = ${var.access_key} >> ~/.aws/credentials\"",
      "bash -c \"echo aws_secret_access_key = ${var.secret_key} >> ~/.aws/credentials\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/credentials\"",
      "chmod 600 ~/.aws/credentials",
      "bash -c \"echo [default] > ~/.aws/config\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/config\"",
      "chmod 600 ~/.aws/config",
      "virtualenv --system-site-packages ~/metrics",
      "source ~/metrics/bin/activate",
      "pip install -U pip",
      "pip install -U setuptools",
      "mkdir -p ~/metrics/etc",
      "mkdir -p ~/metrics/log",
      "mkdir -p ~/metrics/run",
      "mkdir -p ~/metrics/ops",
      "bash -c \"echo >> ~/.bash_profile\"",
      "bash -c \"echo '# source virtualenv' >> ~/.bash_profile\"",
      "bash -c \"echo export METRICS_DIR=$HOME/metrics >> ~/.bash_profile\"",
      "bash -c \"echo source $METRICS_DIR/bin/activate >> ~/.bash_profile\""
    ]
  }
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
  ami                    = "${var.ami}"
  instance_type          = "${var.grq["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.grq["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  root_block_device {
    volume_type = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "${var.grq["docker_storage_dev"]}"
    volume_size = "${var.grq["docker_storage_dev_size"]}"
    volume_type = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "${var.grq["data_dev"]}"
    volume_size = "${var.grq["data_dev_size"]}"
    volume_type = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "${var.grq["persist_dev"]}"
    volume_size = "${var.grq["persist_dev_size"]}"
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
      "sudo yum install -y awscli",
      "sudo mkfs.xfs ${var.grq["persist_dev"]}",
      "sudo bash -c \"echo ${lookup(var.grq, "persist_dev_mount", var.grq["persist_dev"])} ${var.grq["persist"]} auto defaults,nofail,comment=terraform 0 2 >> /etc/fstab\"",
      "sudo mkdir -p ${var.grq["persist"]}",
      "sudo mount ${var.grq["persist"]}",
      "sudo chown -R ops:ops ${var.grq["persist"]}",
      "sudo mkdir -p ${var.grq["persist"]}/var/lib",
      "mkdir -p ~/.aws",
      "chmod 700 ~/.aws",
      "bash -c \"echo [default] > ~/.aws/credentials\"",
      "bash -c \"echo aws_access_key_id = ${var.access_key} >> ~/.aws/credentials\"",
      "bash -c \"echo aws_secret_access_key = ${var.secret_key} >> ~/.aws/credentials\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/credentials\"",
      "chmod 600 ~/.aws/credentials",
      "bash -c \"echo [default] > ~/.aws/config\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/config\"",
      "chmod 600 ~/.aws/config",
      "virtualenv --system-site-packages ~/sciflo",
      "source ~/sciflo/bin/activate",
      "pip install -U pip",
      "pip install -U setuptools",
      "mkdir -p ~/sciflo/etc",
      "mkdir -p ~/sciflo/log",
      "mkdir -p ~/sciflo/run",
      "mkdir -p ~/sciflo/ops",
      "bash -c \"echo >> ~/.bash_profile\"",
      "bash -c \"echo '# source virtualenv' >> ~/.bash_profile\"",
      "bash -c \"echo export SCIFLO_DIR=$HOME/sciflo >> ~/.bash_profile\"",
      "bash -c \"echo source $SCIFLO_DIR/bin/activate >> ~/.bash_profile\""
    ]
  }
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
  ami                    = "${var.ami}"
  instance_type          = "${var.factotum["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.factotum["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  root_block_device {
    volume_type = "gp2"
    delete_on_termination = true
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
      "sudo yum install -y awscli",
      "mkdir -p ~/.aws",
      "chmod 700 ~/.aws",
      "bash -c \"echo [default] > ~/.aws/credentials\"",
      "bash -c \"echo aws_access_key_id = ${var.access_key} >> ~/.aws/credentials\"",
      "bash -c \"echo aws_secret_access_key = ${var.secret_key} >> ~/.aws/credentials\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/credentials\"",
      "chmod 600 ~/.aws/credentials",
      "bash -c \"echo [default] > ~/.aws/config\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/config\"",
      "chmod 600 ~/.aws/config",
      "virtualenv --system-site-packages ~/verdi",
      "source ~/verdi/bin/activate",
      "pip install -U pip",
      "pip install -U setuptools",
      "mkdir -p ~/verdi/etc",
      "mkdir -p ~/verdi/log",
      "mkdir -p ~/verdi/run",
      "mkdir -p ~/verdi/ops",
      "bash -c \"echo >> ~/.bash_profile\"",
      "bash -c \"echo '# source virtualenv' >> ~/.bash_profile\"",
      "bash -c \"echo export VERDI_DIR=$HOME/verdi >> ~/.bash_profile\"",
      "bash -c \"echo source $VERDI_DIR/bin/activate >> ~/.bash_profile\""
    ]
  }
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
  ami                    = "${var.ami}"
  instance_type          = "${var.ci["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.ci["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  root_block_device {
    volume_type = "gp2"
    delete_on_termination = true
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
      "sudo yum install -y awscli",
      "mkdir -p ~/.aws",
      "chmod 700 ~/.aws",
      "bash -c \"echo [default] > ~/.aws/credentials\"",
      "bash -c \"echo aws_access_key_id = ${var.access_key} >> ~/.aws/credentials\"",
      "bash -c \"echo aws_secret_access_key = ${var.secret_key} >> ~/.aws/credentials\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/credentials\"",
      "chmod 600 ~/.aws/credentials",
      "bash -c \"echo [default] > ~/.aws/config\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/config\"",
      "chmod 600 ~/.aws/config",
      "virtualenv --system-site-packages ~/verdi",
      "source ~/verdi/bin/activate",
      "pip install -U pip",
      "pip install -U setuptools",
      "mkdir -p ~/verdi/etc",
      "mkdir -p ~/verdi/log",
      "mkdir -p ~/verdi/run",
      "mkdir -p ~/verdi/ops",
      "bash -c \"echo >> ~/.bash_profile\"",
      "bash -c \"echo '# source virtualenv' >> ~/.bash_profile\"",
      "bash -c \"echo export VERDI_DIR=$HOME/verdi >> ~/.bash_profile\"",
      "bash -c \"echo source $VERDI_DIR/bin/activate >> ~/.bash_profile\""
    ]
  }
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
  ami                    = "${var.ami}"
  instance_type          = "${var.autoscale["instance_type"]}"
  key_name               = "${var.key_name}"
  availability_zone      = "${var.az}"
  tags                   = {
                             Name = "${var.project}-${var.venue}-${var.counter}-pcm-${var.autoscale["name"]}"
                           }
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  root_block_device {
    volume_type = "gp2"
    delete_on_termination = true
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
      "sudo yum install -y awscli",
      "mkdir -p ~/.aws",
      "chmod 700 ~/.aws",
      "bash -c \"echo [default] > ~/.aws/credentials\"",
      "bash -c \"echo aws_access_key_id = ${var.access_key} >> ~/.aws/credentials\"",
      "bash -c \"echo aws_secret_access_key = ${var.secret_key} >> ~/.aws/credentials\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/credentials\"",
      "chmod 600 ~/.aws/credentials",
      "bash -c \"echo [default] > ~/.aws/config\"",
      "bash -c \"echo region = ${var.region} >> ~/.aws/config\"",
      "chmod 600 ~/.aws/config",
      "virtualenv --system-site-packages ~/verdi",
      "source ~/verdi/bin/activate",
      "pip install -U pip",
      "pip install -U setuptools",
      "mkdir -p ~/verdi/etc",
      "mkdir -p ~/verdi/log",
      "mkdir -p ~/verdi/run",
      "mkdir -p ~/verdi/ops",
      "bash -c \"echo >> ~/.bash_profile\"",
      "bash -c \"echo '# source virtualenv' >> ~/.bash_profile\"",
      "bash -c \"echo export VERDI_DIR=$HOME/verdi >> ~/.bash_profile\"",
      "bash -c \"echo source $VERDI_DIR/bin/activate >> ~/.bash_profile\""
    ]
  }
}

output "autoscale_pvt_ip" {
  value = "${aws_instance.autoscale.private_ip}"
}

output "autoscale_pub_ip" {
  value = "${aws_instance.autoscale.public_ip}"
}
