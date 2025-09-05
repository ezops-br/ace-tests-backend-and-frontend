#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_ENI=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_INSIGHTS=true >> /etc/ecs/ecs.config

# Start ECS agent
/usr/libexec/ecs/ecs-init start
