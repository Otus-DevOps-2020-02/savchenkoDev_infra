resource "google_compute_http_health_check" "default-puma-port" {
  name               = "default-puma-connect"
  description        = "Check app port"
  request_path       = "/"
  port               = 9292
  check_interval_sec = 10
  timeout_sec        = 5
}
resource "google_compute_target_pool" "app-pool" {
  name      = "app-pool"
  region    = var.region
  instances = google_compute_instance.app.*.self_link
  health_checks = [
    google_compute_http_health_check.default-puma-port.name
  ]
}
resource "google_compute_forwarding_rule" "load-balancer" {
  name       = "load-balancer"
  target     = google_compute_target_pool.app-pool.self_link
  port_range = "9292"
}
