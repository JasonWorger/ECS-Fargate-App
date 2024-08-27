terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # or the latest version you prefer
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2"
    }
  }
}

# Create a local file
resource "local_file" "local" {
  filename = "${path.module}/local.txt"
  content  = "This is an local file created by Terraform."
}

# Output the file path
output "file_path" {
  value = local_file.local.filename
}

provider "aws" {
  region = "eu-north-1"
}