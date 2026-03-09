terraform {
  backend "s3" {
    bucket         = "pheonix-dev-s3"        # your S3 bucket
    key            = "e-commerce-system/dev/terraform.tfstate"  # path in S3
    region         = "us-east-1"             # change to your bucket region
    dynamodb_table = "terraform-lock"        # optional but recommended
    encrypt        = true                     # encrypt state in S3
  }
}