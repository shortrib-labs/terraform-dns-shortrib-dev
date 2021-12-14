locals {
  dns_name = "shortrib.dev."
}

resource "google_dns_managed_zone" "shortrib_dev" {
  name        = "shortrib-dev"
  dns_name    = local.dns_name
  description = "Domain for shortrib development hosts services"

  dnssec_config {
    state = "on"
  }
}

resource "google_dns_record_set" "shortrib_dev_caa" {
  name         = google_dns_managed_zone.shortrib_dev.dns_name
  managed_zone = google_dns_managed_zone.shortrib_dev.name
  type         = "CAA"
  ttl          = 300

  rrdatas = [
    "0 issue letsencrypt.org"
  ]
}

resource "google_dns_record_set" "minikube" {
  name         = "*.minikube.${google_dns_managed_zone.shortrib_dev.dns_name}"
  managed_zone = google_dns_managed_zone.shortrib_dev.name
  type         = "A"
  ttl          = 300

  rrdatas = [
    "192.168.64.10"
  ]
}

resource "google_dns_record_set" "platform" {
  name         = "platform.${google_dns_managed_zone.shortrib_dev.dns_name}"
  managed_zone = google_dns_managed_zone.shortrib_dev.name
  type         = "CNAME"
  ttl          = 300

  rrdatas = [
    "osdev.crdant.io.beta.tailscale.net."
  ]
}
