resource "google_compute_instance" "reddit-db" {
  name         = "reddit-db-${var.environment}"
  machine_type = "f1-micro"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = var.db_disk_image
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
  tags = ["reddit-db"]
}
resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default-${var.environment}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
