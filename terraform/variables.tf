variable "instances_count" {
  description = "Count App instances"
  default     = 1
}
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
  default     = "appuser:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMkiOGO0ee/BPAe9l/WBvP7nNbi82JNtbhwHYLwfN6/bJ7iVutsjI6iehrkWpEEob0rbYBzrIx2Y8iimI3gZmI0tUScFnbAtFlKQG+53Q8AauJ6vH1EPdN4r1807QRpeapxBLHZf3qMvZEur06lZeG/9SRHPCoZ23IFTq+4sDzPBsjpzh61Pe3IJpe9wmpPfHyom2ngAbhhfwn/RaavRtOqt6WujygHeEuJBnQ4P5mcCUiBA7z6rFgEODd3dwh37zmRlJXs3zeWFbhKb3cSMzvRAryOp0SY8dzUL1sHtfux8PriArMDD3QcQR09HssU6fQa2PZOaCakTJ587UQ5M4l appuser"
}
variable "disk_image" {
  description = "Disk image"
}
