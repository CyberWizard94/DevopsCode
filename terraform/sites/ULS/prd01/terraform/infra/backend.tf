terraform {
    backend "s3" {
        bucket           = "<s3 bucket name>"                      # prod-tfstate
        key              = "prod01/terraform/infra/terraform.tfstate"
        region           = "us-west-2"
        encrypt          = true
        dynamodb_table   = "<dynamodb table>"              #prod01-infra
        role_arn         = "<role arn>"                    #arn:aws:iam:<accountid>:role/<rolename>
    }
}