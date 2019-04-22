aws elbv2 create-target-group --name My-Fargate-TG --protocol HTTP --port 80 --target-type ip --vpc-id $VPC
