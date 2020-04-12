terraform {
  backend "gcs" {
    bucket = "state-remote-storage"
    prefix = "stage"
  }
}
