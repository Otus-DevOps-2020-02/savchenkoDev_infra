variable "project_id" {
  description = "Project ID"
}
variable "user" {
  description = "Username"
}
variable "region" {
  description = "Region"
  default     = "europe-west1"
}
variable "zone" {
  description = "App zone"
  default     = "europe-west1-b"
}
variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}
variable "ssh_keys" {
  description = "Public keys used for ssh access"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db"
}
variable environment {
  description = "Environment for add"
  default     = "production"
}
