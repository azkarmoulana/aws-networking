##### CREATE VPC #####

aws ec2 create-vpc --cidr-block 10.10.0.0/16

## Copy VpcId from output
## Update --vpc-id in the commands below:

aws ec2 create-subnet --vpc-id vpc-08c24bb183d741db9 --cidr-block 10.10.1.0/24

aws ec2 create-subnet --vpc-id vpc-08c24bb183d741db9 --cidr-block 10.10.2.0/24

## Create an Internet Gateway

aws ec2 create-internet-gateway

## Copy InternetGatewayId from the output
## Update the internet-gateway-id and vpc-id in the command below:

aws ec2 attach-internet-gateway --vpc-id vpc-08c24bb183d741db9 --internet-gateway-id igw-0aa19bd4246f502d8

## Create a custom route table

aws ec2 create-route-table --vpc-id vpc-08c24bb183d741db9

## Copy RouteTableId from the output
## Update the route-table-id and gateway-id in the command below:

aws ec2 create-route --route-table-id rtb-073ec521b6d5ceff7 --destination-cidr-block 0.0.0.0/0 --gateway-id igw-0aa19bd4246f502d8

## Check route has been created and is active

aws ec2 describe-route-tables --route-table-id rtb-073ec521b6d5ceff7

## Retrieve subnet IDs
## Update VPC ID in the command below:

aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-08c24bb183d741db9" --query 'Subnets[*].{ID:SubnetId,CIDR:CidrBlock}'

## Associate subnet with custom route table to make public
## Update subnet-id and route-table-id in the command below:

aws ec2 associate-route-table  --subnet-id subnet-00075b1fb13da041d --route-table-id rtb-073ec521b6d5ceff7

## Configure subnet to issue a public IP to EC2 instances
## Update subnet-id in the command below:

aws ec2 modify-subnet-attribute --subnet-id subnet-00075b1fb13da041d --map-public-ip-on-launch


##### LAUNCH INSTANCE INTO SUBNET FOR TESTING #####

## Create a key pair and output to MyKeyPair.pem
## Modify output path accordingly

aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > ./MyKeyPair.pem

## Linux / Mac only - modify permissions

chmod 400 MyKeyPair.pem

## Create security group with rule to allow SSH

aws ec2 create-security-group --group-name SSHAccess --description "Security group for SSH access" --vpc-id vpc-08c24bb183d741db9

## Copy security group ID from output
## Update group-id in the command below:

aws ec2 authorize-security-group-ingress --group-id sg-01f034bccc4510b66 --protocol tcp --port 22 --cidr 0.0.0.0/0

## Launch instance in public subnet using security group and key pair created previously:
## Obtain the AMI ID from the console, update the security-group-ids and subnet-ids

aws ec2 run-instances --image-id ami-06ce513624b435a22 --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids sg-01f034bccc4510b66 --subnet-id subnet-00075b1fb13da041d

## Copy instance ID from output and use in the command below
## Check instance is in running state:

aws ec2 describe-instances --instance-id i-0c7371bbf7888bcdb

## Note the public IP address
## Connect to instance using key pair and public IP

ssh -i MyKeyPair.pem ec2-user@54.253.97.225



##### CLEAN UP #####

## Run commands in the following order replacing all values as necessary

aws ec2 terminate-instances --instance-ids i-0c7371bbf7888bcdb
aws ec2 delete-security-group --group-id sg-01f034bccc4510b66
aws ec2 delete-subnet --subnet-id subnet-02a37f7b7ee80cc01
aws ec2 delete-subnet --subnet-id subnet-00075b1fb13da041d
aws ec2 delete-route-table --route-table-id rtb-073ec521b6d5ceff7
aws ec2 detach-internet-gateway --internet-gateway-id igw-0aa19bd4246f502d8 --vpc-id vpc-08c24bb183d741db9
aws ec2 delete-internet-gateway --internet-gateway-id igw-0aa19bd4246f502d8
aws ec2 delete-vpc --vpc-id vpc-08c24bb183d741db9
