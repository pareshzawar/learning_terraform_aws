provider "aws" {
    region = "us-east-2"
}

############## Remember to remove terraform backedn from below code while executing the first time, as bucket needs to be created
###### before calling the backend. Create  bucket and table first and then update the backend and do the 
##### terraform init, it will prompt you to upload state file remotely, enter yes

resource "aws_s3_bucket" "terraform-state" {
    bucket = "terraform-state-pareshzawar"

    lifecycle {
        prevent_destroy = true
    }

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-up-and-running-locks-pareshzawar"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}
###### Execute below code after creating the bucket (Also do the terraform init first without below code#################
terraform {
    backend "s3" {
        bucket = "terraform-state-pareshzawar"
        key = "global/s3/teraform.tfstate"
        region = "us-east-2"
        dynamodb_table = "terraform-up-and-running-locks-pareshzawar"
        encrypt = true
    }
}
#####################################################################
########### Execute below code after uploading the state file remotely#####
output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform-state.arn
    description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
    value = aws_dynamodb_table.terraform_locks.name
    description = "The name of the DynamoDB Table"
}