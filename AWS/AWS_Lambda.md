AWS Lambda is a serverless computing service provided by Amazon Web Services (AWS) that allows you to run code without provisioning or managing servers

Key Features of AWS Lambda:

1. No Servers to Manage: AWS Lambda automatically runs your code without requiring you to provision or manage servers. Just write the code and upload it to Lambda.
2. Continuous Scaling: Automatically scales your application by running code in response to each trigger. Your code runs in parallel and processes each trigger individually, scaling precisely with the size of the workload.
3. Subsecond Metering: You are charged for every 100ms your code executes and the number of times your code is triggered. This makes it cost-effective because you don't pay for idle server time.
4. Event-driven: Lambda can be triggered by various AWS services such as S3, DynamoDB, Kinesis, SNS, and SQS, making it easy to build applications that respond quickly to new information.
5. Languages Support: Lambda supports multiple programming languages, including Node.js, Python, Java, Go, Ruby, C#, and PowerShell.
6. Integration with AWS Services: Easily integrates with other AWS services, enabling you to build complex applications within the AWS ecosystem.


Getting Started with AWS Lambda:

1. Write Your Function: Develop your function code in one of the supported languages.
2. Set Up the Execution Role: Create an IAM role that AWS Lambda can assume to execute your function on your behalf. This role grants your function permissions to access AWS resources.
3. Create Your Lambda Function: Upload your code to Lambda, either directly in the AWS Management Console or through the AWS CLI/SDKs. Configure the function's settings, including the execution role and memory allocation.
4. Set Up Triggers: Configure the event sources that will trigger your Lambda function. This could be changes in an S3 bucket, updates to a DynamoDB table, HTTP requests via API Gateway, and more.
5. Monitor and Optimize: Use Amazon CloudWatch to monitor the execution and performance of your function. Optimize as necessary by adjusting memory allocation, execution time, and other settings.



Examples of lambda function:
***************************

1. Ec2 instance stop

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
import boto3
region = 'us-west-2'
instances = ['instance1', 'instance2']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.stop_instance(InstanceIds=instances)
    print('stopped your instances:' + str(instances))
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

2. Tag 