terraform {
  backend "gcs" {
   bucket = "terraform-shortrib-dev"
    prefix = "terraform/state"
  }
}
