### Create An AWS EC2 Instance Using AWS CLI

################### 1.  Create a key pair ####################

aws ec2 create-key-pair \
    --key-name DevOpsKeyPair \
    --query 'KeyMaterial' \
    --output text > DevOpsKeyPair.pem
chmod 400 DevOpsKeyPair.pem

############# 2. Choose default subnet ###################################################

# Let's choose the default subnet corresponding to us-east-2a availability zone and store it in a variable
AWS_PUBLIC_SUBNET=$(aws ec2 describe-subnets \
   --filters "Name=availability-zone,Values=us-east-2a" \
   --query "Subnets[0].SubnetId" --output text) && \
  echo "Subnet ID for us-east-2a: $AWS_PUBLIC_SUBNET"

############# 3. Choose Default VPC corresponding to us-east-2a ################################################

DEFAULT_VPC="$(aws ec2 describe-vpcs \
    --filter "Name=isDefault, Values=true" \
    --query "Vpcs[0].VpcId" --output text)"
  echo "VPC ID for us-east-2a: $DEFAULT_VPC"

############# 4. Get the latest AMI ID  ################################################

AWS_AMI=$(aws ec2 describe-images \
    --owners 'amazon' \
    --filters 'Name=name,Values=amzn2-ami-hvm-2.0.20221004.0-x86_64-gp2' \
    'Name=state,Values=available' \
    --query 'sort_by(Images, &CreationDate)[-1].[ImageId]' \
    --output 'text') && \
  echo "AMI ID for us-east-2: $AWS_AMI"

############# 5. Create a security group ################################################

AWS_SECURITY_GROUP=$(aws ec2 create-security-group \
    --group-name DevOpsSG \
    --description "DevOps Security Group" \
    --vpc-id $DEFAULT_VPC \
    --query 'GroupId' \
    --output text) && \
echo "Instance ID $AWS_SECURITY_GROUP"

############# 6. Add a name tag to the security group ###################################

aws ec2 create-tags \
    --resources $AWS_SECURITY_GROUP \
    --tags Key=Name,Value=DevOpsSG

############# 7 Add a rule to the security group #######################################

# Add a rule to the security group
# Add SSH rule
aws ec2 authorize-security-group-ingress \
    --group-id $AWS_SECURITY_GROUP \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --output text

# Add HTTP rule
aws ec2 authorize-security-group-ingress \
    --group-id $AWS_SECURITY_GROUP \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 \
    --output text

# Add HTTP rule
aws ec2 authorize-security-group-ingress \
    --group-id $AWS_SECURITY_GROUP \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0 \
    --output text

# Add HTTPS rule
aws ec2 authorize-security-group-ingress \
    --group-id $AWS_SECURITY_GROUP \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 \
    --output text

############# 8. Set variable  ########################################################

#export AWS_AMI=ami-0931978297f275f71 ### us-east-2 RHEL 
#export AWS_AMI=ami-0e83be366243f524a ### us-east-2 Ubuntu
# export AWS_AMI=ami-06d4b7182ac3480fa  ### us-east-2 Amazon 

export INSTANCE_TYPE=t2.micro
export KEY_PAIR=DevOpsKeyPair
export AWS_EC2_TAG=DevOpsInstance

############# 9. Create an EC2 instance ################################################

EC2_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AWS_AMI \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_PAIR \
    --security-group-ids $AWS_SECURITY_GROUP \
    --subnet-id $AWS_PUBLIC_SUBNET \
    --user-data file://install.sh \
    --associate-public-ip-address \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DevOpsInstance}]' \
    --query 'Instances[0].InstanceId' \
    --output text) && \
echo "Instance ID $EC2_INSTANCE_ID"

################## 10. Check the status of the EC2 instance ###############################

# Check the status of the EC2 instance
# aws ec2 describe-instances --query 'Reservations[*].Instances[*].{InstanceName:Tags[?Key==Name] | [0].Value,PublicIPAddress:PublicIpAddress,ElasticIPAddress:ElasticIpAddress,PublicDnsName:PublicDnsName,InstanceID:InstanceId,InstanceType:InstanceType,InstanceState:State.Name,SubnetID:SubnetId,VPCID:VpcId}' --output table 

################# 11 Get the public ip address of your instance #########################

# Get the public ip address of your instance
AWS_PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text) && \
    echo "INSTANCE IP: $AWS_PUBLIC_IP"

################# 12. SSH into the EC2 instance ##########################################

# SSH into the EC2 instance
echo "ssh -i $KEY_PAIR.pem ec2-user@$AWS_PUBLIC_IP"
