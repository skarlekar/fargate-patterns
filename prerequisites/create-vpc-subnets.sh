#!/bin/bash

export SGRPNAME=My-Fargate-SG
export VPCNAME=My-Fargate-VPC
export VPC=$(aws ec2 describe-vpcs | jq '.Vpcs[] | select(.Tags[].Value == env.VPCNAME) | .VpcId' | sed "s/\"//g")
if [ ! -z "$VPC" ]; then
   echo VPC: $VPC exists. Gathering Subnets and Security Group
   export SUBNET1=$(aws ec2 describe-subnets | jq '.Subnets[] | select(.VpcId == env.VPC) | .SubnetId' | sed "s/\"//g" | sed -n '1p')
   export SUBNET2=$(aws ec2 describe-subnets | jq '.Subnets[] | select(.VpcId == env.VPC) | .SubnetId' | sed "s/\"//g" | sed -n '2p')
   export SECURITYGROUP=$(aws ec2 describe-security-groups --filter Name=vpc-id,Values=$VPC | jq '.SecurityGroups[] | select (.GroupName == env.SGRPNAME) | .GroupId' | sed "s/\"//g") 
   echo VPC:$VPC with Subnets $SUBNET1, $SUBNET2 and Security Group: $SECURITYGROUP exists. Not creating them.
   return 0      
fi

# Create VPC
export VPC=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 | jq '.Vpc.VpcId' |  sed "s/\"//g")
echo VPC: $VPC was created

# Tag the VPC with a name
aws ec2 create-tags --resources $VPC --tags Key=Name,Value=My-Fargate-VPC

# Create Subnets
export SUBNET1=$(aws ec2 create-subnet --availability-zone us-east-1a --vpc-id $VPC --cidr-block 10.0.1.0/24 | jq '.Subnet.SubnetId' |  sed "s/\"//g")
echo SUBNET: $SUBNET1 was created
aws ec2 create-tags --resources $SUBNET1 --tags Key=Name,Value=My-Fargate-Subnet1

export SUBNET2=$(aws ec2 create-subnet --availability-zone us-east-1b --vpc-id $VPC --cidr-block 10.0.0.0/24 | jq '.Subnet.SubnetId' |  sed "s/\"//g")
echo SUBNET: $SUBNET2 was created
aws ec2 create-tags --resources $SUBNET2 --tags Key=Name,Value=My-Fargate-Subnet2

# Create Internet Gateway
export IGWY=$(aws ec2 create-internet-gateway | jq '.InternetGateway.InternetGatewayId' |  sed "s/\"//g")
echo Internet Gateway: $IGWY was created
aws ec2 create-tags --resources $IGWY --tags Key=Name,Value=My-Fargate-IG

#Attach internet-gateway to VPC
aws ec2 attach-internet-gateway --vpc-id $VPC --internet-gateway-id $IGWY

# Create a route table for your VPC
export RTABLE=$(aws ec2  create-route-table --vpc-id $VPC | jq '.RouteTable.RouteTableId' |  sed "s/\"//g")
echo Route Table: $RTABLE was created
aws ec2 create-tags --resources $RTABLE --tags Key=Name,Value=My-Fargate-RT

# Create a route in the route table that points all traffic (0.0.0.0/0) to the Internet gateway
aws ec2 create-route --route-table-id $RTABLE --destination-cidr-block 0.0.0.0/0 --gateway-id $IGWY

# Associate route table with the subnets created earlier
aws ec2 associate-route-table  --subnet-id $SUBNET1 --route-table-id $RTABLE
aws ec2 associate-route-table  --subnet-id $SUBNET2 --route-table-id $RTABLE

# Create a security group in your VPC
export SECURITYGROUP=$(aws ec2 create-security-group --group-name My-Fargate-SG --description "Security group for Fargate Services" --vpc-id $VPC | jq '.GroupId' |  sed "s/\"//g")
echo Security Group: $SECURITYGROUP was created
aws ec2 create-tags --resources $SECURITYGROUP --tags Key=Name,Value=My-Fargate-SG
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUP --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUP --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUP --protocol tcp --port 8080 --cidr 0.0.0.0/0

