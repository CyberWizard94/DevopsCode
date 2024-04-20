Copy files to EC2 and S3 bucket using Terraform

1. Pre-requisites:

AWS Account - You must have a registered AWS account with active billing. If you are working in a corporate AWS environment, then you must have the necessary permissions to create and manage EC2 and S3 buckets.

Terraform Installed - It very obvious that you should have Terraform installed on your working machine. Please refer to this guide on how to install the terraform.

AWS CLI installed - The last thing you need is to have AWS CLI installed on your working machine. Although AWS CLI is not mandatory, it is always recommended to have AWS CLI installed for troubleshooting as well as using the credentials file inside the Terraform file.

2. Setup AWS credentials in the Terraform file:

After completing the pre-requisites you must setup the AWS credentials correctly so that your Terraform code can authenticate and communicate with your AWS environment.

There are a few ways to setup your AWS credentials inside your Terraform file, Please choose either of the following:

Using the credentials file 
***************************

To use the AWS credentials file inside your Terraform file, you must install the AWS CLI beforehand.
Here is a Terraform code snippet:

```
# Note - Please replace the path with your credentials files

provider "aws" {
  region                   = "eu-central-1"
  shared_credentials_files = ["/<path>/<to-aws-credentials>/.aws/credentials"]
}
```


Hard Code Access Key and Secret Access key:
*******************************************

The second way would be to hard code the access key and secret key, but I would not recommend this approach because, with this approach, your AWS credentials might end up in the versioning system.
Here is the example code snippet

```
# Replace the values with your AWS credentials

provider "aws" {
  region     = "eu-central-1"
  access_key = <PLACE-YOUR-ACCESS-KEY>
  secret_key = <PLACE-YOUR-SECRET-KEY>
}
```

Export AWS Credentials as Environment Variables:
************************************************

The third way would be to export the AWS credentials as environment variables Use the following command to export the AWS credentials

```
# Replace the values with your AWS credentials

export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
```

3. Setup an EC2 instance, a security group, and SSH key pair resources.

Let's setup the EC2 instance along with the security group so that the same EC2 instance can be used later to copy the files.

Here is the Terraform code stack for the same:

Step 1- Resource block for an EC2 instance
Step 2- Resource block for Security Group
Step 3- Setup SSH Key Pair & private key


```
# Step 1 - Resource block for EC2 instance
resource "aws_instance" "ec2_example" {

  ami                    = "ami-0767046d1677be5a0"
  instance_type          = "t2.micro"
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.main.id]
}

# Step 2 - Resource block for Security Group
resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0",]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0",]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
}

# Step 3 - Set up the SSH key pair
# To generate SSH key refer to - https://jhooq.com/terraform-generate-ssh-key
resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "<PLACE-YOUR-PUBLIC-KEY>"
}
```

4. Use file provisioner to upload the file to EC2

In the previous steps, we set up the EC2 instance. Now we need to use the file provisioner to copy/upload the files to the EC2 instance.

Let's update the code snipped from the Step-3 and add the file provisioner to the same terraform code tack.

Here is the code snippet:

```
# Step 1: Resource block for EC2 instance
# File provisioner: Added the file provisioner
# To use the file provisioner, you need to specify the following:
# Source: file to be copied from;
# Destination: where file needs to be copied

resource "aws_instance" "ec2_example" {

  ami                    = "ami-0767046d1677be5a0"
  instance_type          = "t2.micro"
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.main.id]

  # File provisioner with source and destination
  provisioner "file" {
    source      = "/home/rahul/Jhooq/keys/aws/test-file.txt"
    destination = "/home/ubuntu/test-file.txt"
  }

  # Connection is necessary for file provisioner to work
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("/home/rahul/Jhooq/keys/aws/aws_key")
    timeout     = "4m"
  }
}


# Step 2 - Resource block for Security Group
resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0",]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0",]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
}

# Step 3 - Set up the SSH key pair
# To generate SSH key refer to - https://jhooq.com/terraform-generate-ssh-key
resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "<PLACE-YOUR-PUBLIC-KEY>"
}
```

5.1 Uploading multiple files to an S3 bucket

Taking the previous example where we have uploaded only a single file to the S3 bucket, let's modify the same code to upload multiple files onto the S3 bucket.

for_each - For uploading more than one file, we must use for_each loop inside the aws_s3_bucket_object resource block.

```
resource "aws_s3_bucket_object" "object1" {
  for_each = fileset("uploads/", "*")
  bucket = aws_s3_bucket.spacelift-test1-s3.id
  key = each.value
  source = "uploads/${each.value}"
  etag = filemd5("uploads/${each.value}")
}
```

6. Initialize and Apply the Terraform configuration.

Once you have completed your terraform stack, it is time to initialize and apply terraform configuration.

Use the following terraform command from the terminal:

```
# Initialize terraform
terraform init

# Plan your changes
terraform plan

# Apply the changes
terraform apply
```