provider "google" {
  version = "2.15"

  project = var.project_id
  region  = var.region
}
resource "google_compute_instance" "app" {
  count        = var.instances_count
  name         = "reddit-terraform-${count.index}"
  machine_type = "f1-micro"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = "reddit-base"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}appuser1:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMkiOGO0ee/BPAe9l/WBvP7nNbi82JNtbhwHYLwfN6/bJ7iVutsjI6iehrkWpEEob0rbYBzrIx2Y8iimI3gZmI0tUScFnbAtFlKQG+53Q8AauJ6vH1EPdN4r1807QRpeapxBLHZf3qMvZEur06lZeG/9SRHPCoZ23IFTq+4sDzPBsjpzh61Pe3IJpe9wmpPfHyom2ngAbhhfwn/RaavRtOqt6WujygHeEuJBnQ4P5mcCUiBA7z6rFgEODd3dwh37zmRlJXs3zeWFbhKb3cSMzvRAryOp0SY8dzUL1sHtfux8PriArMDD3QcQR09HssU6fQa2PZOaCakTJ587UQ5M4l appuser1"
  }
  tags = ["reddit-app"]
  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = var.user
    agent       = false
    private_key = file(var.private_key_path)
  }
  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }
  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = join("\n", var.ssh_keys)
}
resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
