provider "openstack" {
  user_name   = "${var.user_name}"
  tenant_name = "${var.tenant_name}"
  tenant_id   = "${var.tenant_id}"
  password    = "${var.password}"
  auth_url    = "${var.auth_url}"
  region      = "${var.region}"
}


######################
# mozart
######################

resource "openstack_blockstorage_volume_v2" "mozart_docker_storage" {
  name = "mozart_docker_storage"
  size = "${var.mozart["docker_storage_size"]}"
}

resource "openstack_blockstorage_volume_v2" "mozart_data" {
  name = "mozart_data"
  size = "${var.mozart["data_size"]}"
}

resource "openstack_compute_instance_v2" "mozart" {
  name                   = "${var.project}-${var.venue}-${var.counter}-pcm-${var.mozart["name"]}"
  image_id               = "${var.mozart["image_id"]}"
  flavor_id              = "${var.mozart["flavor_id"]}"
  key_pair               = "${var.key_pair}"
  security_groups        = "${var.security_groups}"

  network {
    uuid = "${var.network["uuid"]}"
    name = "${var.network["name"]}"
  }
}

resource "openstack_compute_volume_attach_v2" "attached_mozart_docker_storage" {
  instance_id = "${openstack_compute_instance_v2.mozart.id}"
  volume_id = "${openstack_blockstorage_volume_v2.mozart_docker_storage.id}"
}

resource "openstack_compute_volume_attach_v2" "attached_mozart_data" {
  instance_id = "${openstack_compute_instance_v2.mozart.id}"
  volume_id = "${openstack_blockstorage_volume_v2.mozart_data.id}"
}

#resource "openstack_networking_floatingip_v2" "mozart_ip" {
#  pool = "${var.pool}"
#}
#
#resource "openstack_compute_floatingip_associate_v2" "mozart_ip" {
#  floating_ip = "${openstack_networking_floatingip_v2.mozart_ip.address}"
#  instance_id = "${openstack_compute_instance_v2.mozart.id}"
#}


######################
# metrics
######################

resource "openstack_blockstorage_volume_v2" "metrics_docker_storage" {
  name = "metrics_docker_storage"
  size = "${var.metrics["docker_storage_size"]}"
}

resource "openstack_blockstorage_volume_v2" "metrics_data" {
  name = "metrics_data"
  size = "${var.metrics["data_size"]}"
}

resource "openstack_compute_instance_v2" "metrics" {
  name                   = "${var.project}-${var.venue}-${var.counter}-pcm-${var.metrics["name"]}"
  image_id               = "${var.metrics["image_id"]}"
  flavor_id              = "${var.metrics["flavor_id"]}"
  key_pair               = "${var.key_pair}"
  security_groups        = "${var.security_groups}"

  network {
    uuid = "${var.network["uuid"]}"
    name = "${var.network["name"]}"
  }
}

resource "openstack_compute_volume_attach_v2" "attached_metrics_docker_storage" {
  instance_id = "${openstack_compute_instance_v2.metrics.id}"
  volume_id = "${openstack_blockstorage_volume_v2.metrics_docker_storage.id}"
}

resource "openstack_compute_volume_attach_v2" "attached_metrics_data" {
  instance_id = "${openstack_compute_instance_v2.metrics.id}"
  volume_id = "${openstack_blockstorage_volume_v2.metrics_data.id}"
}

#resource "openstack_networking_floatingip_v2" "metrics_ip" {
#  pool = "${var.pool}"
#}
#
#resource "openstack_compute_floatingip_associate_v2" "metrics_ip" {
#  floating_ip = "${openstack_networking_floatingip_v2.metrics_ip.address}"
#  instance_id = "${openstack_compute_instance_v2.metrics.id}"
#}


######################
# grq
######################

resource "openstack_blockstorage_volume_v2" "grq_docker_storage" {
  name = "grq_docker_storage"
  size = "${var.grq["docker_storage_size"]}"
}

resource "openstack_blockstorage_volume_v2" "grq_data" {
  name = "grq_data"
  size = "${var.grq["data_size"]}"
}

resource "openstack_compute_instance_v2" "grq" {
  name                   = "${var.project}-${var.venue}-${var.counter}-pcm-${var.grq["name"]}"
  image_id               = "${var.grq["image_id"]}"
  flavor_id              = "${var.grq["flavor_id"]}"
  key_pair               = "${var.key_pair}"
  security_groups        = "${var.security_groups}"

  network {
    uuid = "${var.network["uuid"]}"
    name = "${var.network["name"]}"
  }
}

resource "openstack_compute_volume_attach_v2" "attached_grq_docker_storage" {
  instance_id = "${openstack_compute_instance_v2.grq.id}"
  volume_id = "${openstack_blockstorage_volume_v2.grq_docker_storage.id}"
}

resource "openstack_compute_volume_attach_v2" "attached_grq_data" {
  instance_id = "${openstack_compute_instance_v2.grq.id}"
  volume_id = "${openstack_blockstorage_volume_v2.grq_data.id}"
}

#resource "openstack_networking_floatingip_v2" "grq_ip" {
#  pool = "${var.pool}"
#}
#
#resource "openstack_compute_floatingip_associate_v2" "grq_ip" {
#  floating_ip = "${openstack_networking_floatingip_v2.grq_ip.address}"
#  instance_id = "${openstack_compute_instance_v2.grq.id}"
#}


######################
# factotum
######################

resource "openstack_blockstorage_volume_v2" "factotum_docker_storage" {
  name = "factotum_docker_storage"
  size = "${var.factotum["docker_storage_size"]}"
}

resource "openstack_blockstorage_volume_v2" "factotum_data" {
  name = "factotum_data"
  size = "${var.factotum["data_size"]}"
}

resource "openstack_compute_instance_v2" "factotum" {
  name                   = "${var.project}-${var.venue}-${var.counter}-pcm-${var.factotum["name"]}"
  image_id               = "${var.factotum["image_id"]}"
  flavor_id              = "${var.factotum["flavor_id"]}"
  key_pair               = "${var.key_pair}"
  security_groups        = "${var.security_groups}"

  network {
    uuid = "${var.network["uuid"]}"
    name = "${var.network["name"]}"
  }
}

resource "openstack_compute_volume_attach_v2" "attached_factotum_docker_storage" {
  instance_id = "${openstack_compute_instance_v2.factotum.id}"
  volume_id = "${openstack_blockstorage_volume_v2.factotum_docker_storage.id}"
}

resource "openstack_compute_volume_attach_v2" "attached_factotum_data" {
  instance_id = "${openstack_compute_instance_v2.factotum.id}"
  volume_id = "${openstack_blockstorage_volume_v2.factotum_data.id}"
}

#resource "openstack_networking_floatingip_v2" "factotum_ip" {
#  pool = "${var.pool}"
#}
#
#resource "openstack_compute_floatingip_associate_v2" "factotum_ip" {
#  floating_ip = "${openstack_networking_floatingip_v2.factotum_ip.address}"
#  instance_id = "${openstack_compute_instance_v2.factotum.id}"
#}


######################
# ci
######################

resource "openstack_blockstorage_volume_v2" "ci_docker_storage" {
  name = "ci_docker_storage"
  size = "${var.ci["docker_storage_size"]}"
}

resource "openstack_blockstorage_volume_v2" "ci_data" {
  name = "ci_data"
  size = "${var.ci["data_size"]}"
}

resource "openstack_compute_instance_v2" "ci" {
  name                   = "${var.project}-${var.venue}-${var.counter}-pcm-${var.ci["name"]}"
  image_id               = "${var.ci["image_id"]}"
  flavor_id              = "${var.ci["flavor_id"]}"
  key_pair               = "${var.key_pair}"
  security_groups        = "${var.security_groups}"

  network {
    uuid = "${var.network["uuid"]}"
    name = "${var.network["name"]}"
  }
}

resource "openstack_compute_volume_attach_v2" "attached_ci_docker_storage" {
  instance_id = "${openstack_compute_instance_v2.ci.id}"
  volume_id = "${openstack_blockstorage_volume_v2.ci_docker_storage.id}"
}

resource "openstack_compute_volume_attach_v2" "attached_ci_data" {
  instance_id = "${openstack_compute_instance_v2.ci.id}"
  volume_id = "${openstack_blockstorage_volume_v2.ci_data.id}"
}

#resource "openstack_networking_floatingip_v2" "ci_ip" {
#  pool = "${var.pool}"
#}
#
#resource "openstack_compute_floatingip_associate_v2" "ci_ip" {
#  floating_ip = "${openstack_networking_floatingip_v2.ci_ip.address}"
#  instance_id = "${openstack_compute_instance_v2.ci.id}"
#}
