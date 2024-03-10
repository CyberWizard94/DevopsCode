what is null resource?
As name suggets null resource will not exists in your infrastructure. The reason is there is no terraform state associated with it, due to which you can update the null_resource inside your terraform any number of times.

1. How does Terraform NULL RESOURCE Work?

Terraform null_resource does not have a state which means it will be executed as soon as you run $ terraform apply command but no state will be saved.

Keep in mind when you execute $terraform apply command the null_resource will always execute it once.

++++++++++++++++++++++++++++++++++++++++++++++++++
#main.tf

provider "aws" {
  region     = "eu-central-1"
  shared_credentials_files = ["/Users/rahulwagh/.aws/credentials"]
}

resource "aws_instance" "ec2_example" {
  ami           = "ami-0767046d1677be5a0"
  instance_type =  "t2.micro"
  tags = {
    Name = "Terraform EC2 "
  }
}

# The following null resource will print message "Hello World"
resource "null_resource" "null_resource_simple" {
  provisioner "local-exec" {
    command = "echo Hello World"
  }
}
++++++++++++++++++++++++++++++++++++++++++++++++++

2. What is the trigger inside null_resource?

The trigger is a block inside the null_resource which holds key-value pair. But to understand the trigger please have look at the following points -

As the name suggest trigger, it will execute local-exec, remote-exec or data block.
trigger will only work when it detects the change in the key-value pair
trigger can only work once if key-value is changed once but on the other hand if the key-value pair changes its value every time it will execute the every time you run $terraform apply command.

Example-
++++++++++++++++++++++++++++++++++++++++++++++++++
#main.tf 

provider "aws" {
  region     = "eu-central-1"
  shared_credentials_files = ["/Users/rahulwagh/.aws/credentials"]
}

resource "aws_instance" "ec2_example" {
  ami           = "ami-0767046d1677be5a0"
  instance_type =  "t2.micro"
  tags = {
    Name = "Terraform EC2 "
  }
}

# The following null resource has the trigger
resource "null_resource" "null_resource_simple" {
  
  # This trigger will only execute once when it detects the instance id of EC2 instance 
  triggers = {
    id = aws_instance.ec2_example.id    # to execute it every time replace - id = time()
  }
  provisioner "local-exec" {
    command = "echo Hello World"
  }
}

++++++++++++++++++++++++++++++++++++++++++++++++++

Use Case 1 - null_resource with local provisioner

n the previous section, we have seen a very basic example of local-exec provisioner where we have executed hello world program. But with null resource and local-exec provisioner you can do more.

Here are a few examples -

1. Run multiple commands- The local-exec provisioner is not limited to running single command but instead, you can run multiple commands within local-exec provisioner using the null_resource.
++++++++++++++++++++++++++++++++++++++++++++++++++
resource "null_resource" "null_resource_simple" {
  
  triggers = {
    id = aws_instance.ec2_example.id  
  }
  provisioner "local-exec" {
    command = <<-EOT
      chmod +x install-istio.sh  
      ./install-istio.sh
    EOT
  }
}
++++++++++++++++++++++++++++++++++++++++++++++++++

Use Case 2 - null_resource with remote provisioner
The second use case for null_resource is to use it with remote_provisioner. With the help of remote_provisioner you can execute commands on the remote machine. To explain a bit further we are going to take an example in which -

First we will setup the ec2 instance
Write null_resource and remote-exec provisioner
Use the remote-exec provisioner to connect remote EC2 instance
After a successful connection create a txt file.
Here is how the terraform code would look like -

++++++++++++++++++++++++++++++++++++++++++++++++++
resource "aws_instance" "ec2_example" {
  ami           = "ami-0767046d1677be5a0"
  instance_type =  "t2.micro"
  tags = {
    Name = "Terraform EC2 "
  }
}

resource "null_resource" "null_resource_with_remote_exec" {

  triggers = {
    id = aws_instance.ec2_example.id
  }
  
  provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
  }
  
  connection {
    type        = "ssh"
    host        = ec2_example.id
    user        = "ubuntu"
    private_key = file("/home/rahul/Jhooq/keys/aws/aws_key")
    timeout     = "4m"
  }

}
++++++++++++++++++++++++++++++++++++++++++++++++++

Use Case 3 - Using trigger to execute null_resource everytime

In the final use case, we are going to see how to execute trigger every time inside the null_resource. Always remember trigger inside the null_resource always retains and key-value pair. If there is an update in the value of key-value pair then null_resource will execute every time.

Here is a Terraform code example -

++++++++++++++++++++++++++++++++++++++++++++++++++
# main.tf

provider "aws" {
  region     = "eu-central-1"
  shared_credentials_files = ["/Users/rahulwagh/.aws/credentials"]
}

resource "aws_instance" "ec2_example" {
  ami           = "ami-0767046d1677be5a0"
  instance_type =  "t2-micro"
  tags = {
    Name = "Terraform EC2 "
  }
}

# This null_resource will be executed everytime because of id = time().
resource "null_resource" "null_resource_simple" {
  
  # Look carefully in the trigger we have assigned time() which we change value every time you run $terraform apply command.
  triggers = {
    id = time()
  }

  provisioner "local-exec" {
    command = "echo Hello World"
  }
} 
++++++++++++++++++++++++++++++++++++++++++++++++++
time() - Time function is just an example in which we always get a different value and due to which the local-exec provisioner gets executed all the time.