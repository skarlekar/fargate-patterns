export DNS=$(aws elbv2 describe-load-balancers | jq '.LoadBalancers[] | if .LoadBalancerName == "My-Fargate-ALB" then .DNSName else null end' | grep -v null | sed "s/\"//g")

ab -n 100000 -c 100 -s 120 http://$DNS/
