terraform {
  backend "consul" {
    address = "localhost:8500"
    scheme  = "http"
    path    = "website/terraform_state"
  }
}
