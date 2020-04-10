variable public_key_path {
 description = "Path to the public key used to connect to instance"
}
variable private_key_path {
 description = "Path to the public key used to connect to instance"
}
variable zone {
  description = "Zone"
}
variable user {
  description = "App user"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default = "reddit-app-base"
}
variable environment {
  description = "Environment for app"
}
variable database_url {
  description = "MongoDB URL"
}
