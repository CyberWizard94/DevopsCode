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