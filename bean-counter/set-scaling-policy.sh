aws application-autoscaling register-scalable-target \
--service-namespace ecs \
--scalable-dimension ecs:service:DesiredCount \
--resource-id service/bean-counter-cluster/bean-counter-service \
--min-capacity 2 \
--max-capacity 4

aws application-autoscaling put-scaling-policy \
--service-namespace ecs \
--scalable-dimension ecs:service:DesiredCount \
--resource-id service/bean-counter-cluster/bean-counter-service \
--policy-name cpu75-target-tracking-scaling-policy \
--policy-type TargetTrackingScaling \
--target-tracking-scaling-policy-configuration file://scaling-policy.json
