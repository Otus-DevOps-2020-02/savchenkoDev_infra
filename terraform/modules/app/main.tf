resource "google_compute_instance" "reddit-app" {
  name         = "reddit-app-${var.environment}"
  machine_type = "f1-micro"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = var.app_disk_image
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.app_ip.address
    }
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
  tags = ["reddit-app"]
  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = var.user
    agent       = false
    private_key = file(var.private_key_path)
  }
  provisioner "local-exec" {
    command = "echo DATABASE_URL=$DATABASE_URL >> /tmp/app.env"
    environment = {
      DATABASE_URL = var.database_url
    }
  }
  provisioner "file" {
    source      = "/tmp/app.env"
    destination = "/home/appuser/vars"
  }
  provisioner "file" {
    source      = "${path.module}/puma.service"
    destination = "/tmp/puma.service"
  }
  provisioner "remote-exec" {
    script = "${path.module}/deploy.sh"
  }
}
resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default-${var.environment}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip-${var.environment}"
}
