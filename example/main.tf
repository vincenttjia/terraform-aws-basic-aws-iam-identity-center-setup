module "this" {
  source = "./../"

  users = [
    {
      email       = "example@example.com"
      given_name  = "John"
      family_name = "Doe"
    }
  ]
}

provider "aws" {
  region = "ap-southeast-1"
}
