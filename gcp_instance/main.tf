resource "google_compute_instance" "default" {
  name         = var.tags
  machine_type = "f1-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      //image = "debian-cloud/debian-9"
      image = var.image
    }
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.subnetwork
    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  metadata_startup_script = "sudo apt-get update && sudo apt-get install apache2 -y && echo '<!doctype html><html><body><h1>avx test instance'"
  metadata = {
    ssh-keys = "mohsinkamal:${var.public_key}"
  }
  // Apply the firewall rule to allow external IPs to access this instance
  tags = [var.tags]
}

resource "google_compute_firewall" "Testinstance" {
  name    = var.tags
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }
  allow {
    protocol = "icmp"
  }
  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.tags]
}

output "ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}
