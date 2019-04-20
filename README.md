# Fargate Design Patterns

## Compendium and Code Examples of AWS Fargate Patterns.

**AWS Fargate** is the Uber of container service allowing engineers to hail a container by specifying their compute and memory needs. By providing an incredible on-demand flexibility and removing the burden of resource provisioning just as Lambda did years ago to servers, Fargate is disrupting the container management technology.

## Introduction
Making software behave predictably in different environments where it is deployed during the lifecycle of an application is one of the biggest challenges of development. Subtle differences in system software on which developers have no control - even in same operating systems - can cause unexpected behaviors and are hard to debug and fix. Containers were invented to solve this problem. Containers encapsulates entire runtime environments for an application or service including dependent libraries, configurations which are just enough to run the application into software packages that are portable across operating systems. By sandboxing the application into just enough space and opening just the right ports for communication with the outside world, containers also increases the security of an application by reducing blast radius and increasing the number of services that can be run on a unit of hardware.

First released in 2013, Docker introduced the concept of containers. Kubernetes followed in 2014 allowing multiple Docker nodes running on different heterogenous hosts to be orchestrated by automating provisioning, networking, load-balancing, security and scaling across these nodes through a single dashboard or command line. Both of these technologies required upkeep of the underlying cluster of servers & operating system through upgrades, patching, rehydration and security management. Amazon introduced ECS and EKS as platform services to streamline this management process for Docker and Kubernetes respectively.

## What is AWS Fargate?

Put simply, **AWS Fargate** is a managed, compute engine provided by AWS to run your containers without having to worry about managing a cluster of servers. You don't have to choose server types, upgrade or patch servers or optimize container packing on your clusters. 

This is analogous to hailing an *Uber* car service. With Uber you just tell what size car you want based on how many people are riding, if you want a car seat or want the car to be wheel-chair accessible. You don’t specify a Lexus or a Toyota. With Fargate, all you do is package your application in containers, specify the CPU and memory requirements, define networking and IAM policies, and launch the application. Fargate takes care of scaling so that you don't have to worry about provisioning enough compute resources for your containers to scale out or scale them in when they are not utilized.  In essence, Fargate separates the task of running containers from the task of managing the underlying infrastructure. Developers can simply specify the resources that each container requires, and Fargate will handle the rest. ***As a result, applications deployed on Fargate can save you time, man power, and money***.

If you are used to traditional container management, you will really appreciate Fargate allowing you to focus on the 'Dev' part of designing and building your applications and removing the 'Ops' part of managing infrastructure from your 'DevOps' responsibilities. 

## Fargate - the Good, Bad & Ugly
### Pay Per Use
Fargate is a good choice if you are leaving a lot of compute power and memory foot-print unused. Unlike ECS or EKS, you only pay for the compute and memory that you actually use. It also integrates well with other AWS services allowing you to schedule tasks and run them based on events while automatically fading them out when not in use.

### Low Complexity
With its Container-as-a-Service model, you don't have to worry about the underlying infrastructure you need for deploying your container, how you will optimize usage or secure them. Instead you focus reduces to the four walls of your container - its size, power and communication with the outside world aka memory, CPU and networking.

### Better Security
Since you don't have to worry about securing the entire cluster of servers, your security concern is reduced to security within the container
 
## Focus of this workshop

In this workshop, we will explore three design patterns viz., the ***Container-on-Demand***, ***Scaling-Container*** and ***Sidecar-Assembly*** patterns that allows Fargate to be used just like Lambdas for heavy on-demand tasks where Lambda is not suitable, or run containers traditionally but without having to manage infrastructure.

We will use the *Container-on-Demand* pattern to build an on-demand video thumbnail service  on-demand task to generate thumbnail images from video files. With this pattern you can spin the containers on demand and immediately decommission after the task is run.

We will use the *Scaling-Container* to build the an auto-scaling service that finds the value of the coins thrown on a table from an image. With this pattern you will have a small footprint always running and scale up or down as the processing demands.

Later we will explore the *Sidecar-Assembly* pattern to assemble otherwise fully functional services running in containers to build an application that has expanded capabilities beyond what is provided by these services. In essence, to reinforce that the whole is greater than sum of its parts.

## *Container-on-Demand* Pattern
### Problem

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTU5Mjc1NDYyNiwtMTk0MDQ2NjQ4MSwtMT
IyOTkxNTExMCwyNjA4NDQzNTQsLTE3NDM0NjQ0NjldfQ==
-->