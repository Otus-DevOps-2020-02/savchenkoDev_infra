provider "google" {
  version = "2.15"

  project = var.project_id
  region  = var.region
}
module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["178.46.106.147"]
  environment   = var.environment
}
module "db" {
  source           = "../modules/db"
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  user             = var.user
  zone             = var.zone
  db_disk_image    = var.db_disk_image
  environment      = var.environment
}
module "app" {
  source           = "../modules/app"
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  user             = var.user
  zone             = var.zone
  app_disk_image   = var.app_disk_image
  environment      = var.environment
  database_url     = "${module.db.db_internal_ip}:27017"
}
