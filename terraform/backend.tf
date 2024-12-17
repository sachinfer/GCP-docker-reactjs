terraform {
  backend "gcs" {
    bucket = "sachin-terraform-state"
    prefix = "terraform/state"
  }
}