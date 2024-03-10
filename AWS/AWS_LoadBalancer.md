To Create loadbalancer using the AWS Managment console below tasks should be performed

step 1: configure target groups
step 2: Register targets
step 3: configure loadbalancer and listeners
step 4: Test the load balancer



Step 1: configure target groups
#########################################################################################

1. open EC2 Console
2. In the navigation pane, choose Targets Groups
3. Choose Create target Group
4. In Basic configuration section, set following parameters:
    a. Choose target type
       1. Instance ID
       2. IP Address
       3. Lambda Function
    b. Enter name of target group
    c. Modify Port and protocol as needed
    d. If it is Instance or i.p address, choose IPv4 or IPv6 as the Ip address type, otherwise skip this step
        Note that only targets that have the selected IP address type can be included in this target group. The IP address type cannot be changed after the target group is created.
    e. Select VPC
    f. For Protocol version, select HTTP1 when the request protocol is HTTP/1.1 or HTTP/2; select HTTP2, when the request     pr otocol is HTTP/2 or gRPC; and select gRPC, when the request protocol is gRPC.
5. In the Health checks section, modify the default settings as needed. For Advanced health check settings, choose the health check port, count, timeout, interval, and specify success codes. If health checks consecutively exceed the Unhealthy threshold count, the load balancer takes the target out of service. If health checks consecutively exceed the Healthy threshold count, the load balancer puts the target back in service.
6. (Optional) Add one or more tags as follows:

Expand the Tags section.

Choose Add tag.

Enter the tag Key and tag Value. Allowed characters are letters, spaces, numbers (in UTF-8), and the following special characters: + - = . _ : / @. Do not use leading or trailing spaces. Tag values are case-sensitive.

7. Choose Next.

Step 2: Register targets

You can register EC2 instances, IP addresses, or Lambda functions as targets in a target group. This is an optional step to create a load balancer. However, you must register your targets to ensure that your load balancer routes traffic to them.

1. In the Register targets page, add one or more targets as follows:

       If the target type is Instances, select one or more instances, enter one or more ports, and then choose Include as pending below.

       If the target type is IP addresses, do the following:

          a. Select a network VPC from the list, or choose Other private IP addresses.
          b. Enter the IP address manually, or find the IP address using instance details. You can enter up to five IP addresses at a time.
          c. Enter the ports for routing traffic to the specified IP addresses.
          d. Choose Include as pending below.

       If the target type is Lambda, select a Lambda function, or enter a Lambda function ARN, and then choose Include as pending below.

2. Choose Create target group.
********************************

Step 3: Configure a load balancer and a listener

To create an Application Load Balancer, you must first provide basic configuration information for your load balancer, such as a name, scheme, and IP address type. Then, you provide information about your network, and one or more listeners. A listener is a process that checks for connection requests. It is configured with a protocol and a port for connections from clients to the load balancer. For more information about supported protocols and ports

To configure your load balancer and listener

1. In the navigation pane, choose Load Balancers.
2. Choose Create Load Balancer.
3. Under Application Load Balancer, choose Create.
4. Basic configuration
       a. For Load balancer name, enter a name for your load balancer. For example, my-alb. The name of your Application Load   Balancer must be unique within your set of Application Load Balancers and Network Load Balancers for the Region. Names can have a maximum of 32 characters, and can contain only alphanumeric characters and hyphens. They can not begin or end with a hyphen, or with internal-. The name of your Application Load Balancer cannot be changed after it's created.
       b. For Scheme, choose Internet-facing or Internal. An internet-facing load balancer routes requests from clients to targets over the internet. An internal load balancer routes requests to targets using private IP addresses.
       c. For IP address type, choose IPv4 or Dualstack. Use IPv4 if your clients use IPv4 addresses to communicate with the load balancer. Choose Dualstack if your clients use both IPv4 and IPv6 addresses to communicate with the load balancer.

5. Network mapping
       a. For VPC, select the VPC that you used for your EC2 instances. If you selected Internet-facing for Scheme, only VPCs with an internet gateway are available for selection.
       b. For Mappings, enable zones for your load balancer by selecting subnets as follows:
          Subnets from two or more Availability Zones
          Subnets from one or more Local Zones
          One Outpost subnet
        For internal load balancers, the IPv4 and IPv6 addresses are assigned from the subnet CIDR.
        If you enabled Dualstack mode for the load balancer, select subnets with both IPv4 and IPv6 CIDR blocks.
6. For Security groups, select an existing security group, or create a new one.
The security group for your load balancer must allow it to communicate with registered targets on both the listener port and the health check port. The console can create a security group for your load balancer on your behalf with rules that allow this communication. You can also create a security group and select it instead. For more information

7. For Listeners and routing, the default listener accepts HTTP traffic on port 80. You can keep the default protocol and port, or choose different ones. For Default action, choose the target group that you created. You can optionally choose Add listener to add another listener (for example, an HTTPS listener).

8. (Optional) If using an HTTPS listener
For Security policy, we recommend that you always use the latest predefined security policy.
a. For Default SSL/TLS certificate, the following options are available:
    If you created or imported a certificate using AWS Certificate Manager, select From ACM, then select the certificate from Select a certificate.

    If you imported a certificate using IAM, select From IAM, and then select your certificate from Select a certificate.

    If you have a certificate to import but ACM is not available in your Region, select Import, then select To IAM. Type the name of the certificate in the Certificate name field. In Certificate private key, copy and paste the contents of the private key file (PEM-encoded). In Certificate body, copy and paste the contents of the public key certificate file (PEM-encoded). In Certificate Chain, copy and paste the contents of the certificate chain file (PEM-encoded), unless you are using a self-signed certificate and it's not important that browsers implicitly accept the certificate.

b. (Optional) To enable mutual authentication, under Client certificate handling enable Mutual authentication (mTLS).

When enabled, the default mutual TLS mode is passthrough.

If you select Verify with Trust Store:

    By default, connections with expired client certificates are rejected. To change this behavior expand Advanced mTLS settings, then under Client certificate expiration select Allow expired client certificates.
 
    Under Trust Store choose an existing trust store, or choose New trust store.
 
    If you chose New trust store, provide a Trust store name, the S3 URI Certificate Authority location, and optionally an S3 URI Certificate revocation list location.

9. (Optional) You can integrate other services with your load balancer during creation, under Optimize with service integrations.

    You can choose to include AWS WAF security protections for your load balancer, with an existing or automatically created web ACL.
    You can choose to have AWS Global Accelerator create an accelerator for you and associate your load balancer with the accelerator. The accelerator name can have the following characters (up to 64 characters): a-z, A-Z, 0-9, . (period), and - (hyphen).

11. Tag and create

    a. (Optional) Add a tag to categorize your load balancer. Tag keys must be unique for each load balancer. Allowed characters are letters, spaces, numbers (in UTF-8), and the following special characters: + - = . _ : / @. Do not use leading or trailing spaces. Tag values are case-sensitive.

    b. Review your configuration, and choose Create load balancer. A few default attributes are applied to your load balancer during creation. You can view and edit them after creating the load balancer. For more information
