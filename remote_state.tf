terraform {
  backend s3 {
    encrypt       = true
    bucket        = "terraform-durianpay-test-yauma"
    region        = "us-east-1"
    key           = "durianpay-test/terraform.tfstate"
    # endpoints = {
    #   s3 = "http://s3.localhost.localstack.cloud:4566"
    # }
  }
}
