# Fargate Design Patterns

## Compendium and Code Examples of AWS Fargate Patterns.

**AWS Fargate** is the Uber of container service allowing engineers to hail a container by specifying their compute and memory needs. By providing incredible on-demand flexibility and removing the burden of resource provisioning just as Lambda did years ago to servers, Fargate is disrupting the container management technology.

## Introduction
Making software behave predictably in different environments where it is deployed during the lifecycle of an application is one of the biggest challenges of development. Subtle differences in system software on which developers have no control - even in same operating systems - can cause unexpected behaviors and are hard to debug and fix. Containers were invented to solve this problem. Containers encapsulate entire runtime environments for an application or service including dependent libraries, configurations which are just enough to run the application into software packages that are portable across operating systems. By sandboxing the application into just enough space and opening just the right ports for communication with the outside world, containers also increase the security of an application by reducing blast radius and increasing the number of services that can be run on a unit of hardware.

First released in 2013, Docker introduced the concept of containers. Kubernetes followed in 2014 allowing multiple Docker nodes running on different heterogenous hosts to be orchestrated by automating provisioning, networking, load-balancing, security and scaling across these nodes through a single dashboard or command line. Both of these technologies required the upkeep of the underlying cluster of servers & operating system through upgrades, patching, rehydration, and security management. Amazon introduced ECS and EKS as platform services to streamline this management process for Docker and Kubernetes respectively.

## What is AWS Fargate?

Put simply, **AWS Fargate** is a managed, compute engine provided by AWS to run your containers without having to worry about managing a cluster of servers. You don't have to choose server types, upgrade or patch servers or optimize container packing on your clusters. 

This is analogous to hailing an *Uber* car service. With Uber, you just tell what size car you want based on how many people are riding, if you want a car seat or want the car to be wheel-chair accessible. You don’t specify a Lexus or a Toyota. With Fargate, all you do is package your application in containers, specify the CPU and memory requirements, define networking and IAM policies, and launch the application. Fargate takes care of scaling so that you don't have to worry about provisioning enough compute resources for your containers to scale out or scale them in when they are not utilized.  In essence, Fargate separates the task of running containers from the task of managing the underlying infrastructure. Developers can simply specify the resources that each container requires, and Fargate will handle the rest. ***As a result, applications deployed on Fargate can save you time, manpower, and money***.

If you are used to traditional container management, you will really appreciate Fargate allowing you to focus on the 'Dev' part of designing and building your applications and removing the 'Ops' part of managing infrastructure from your 'DevOps' responsibilities. 

## Fargate - the Good, Bad & Ugly
###  Good & Bad: Pay Per Use
Fargate is a good choice if you are leaving a lot of compute power and memory foot-print unused. Unlike ECS or EKS, you only pay for the compute and memory that you actually use. It also integrates well with other AWS services allowing you to schedule tasks and run them based on events while automatically fading them out when not in use.

While Fargate provides you an opportunity to cut costs by charging you only for the time your container is running, the average per-hour cost for running Fargate is more than the per-hour cost of running ECS or EKS in spite of [major price reduction in Jan 2019](https://aws.amazon.com/blogs/compute/aws-fargate-price-reduction-up-to-50/) proving once again that there is no free lunch. The cost differential is the price you pay for not having to deal with the complexity of managing infrastructure or investing in time and resources to deal with the cluster management that comes with the traditional solutions. 

As a result, the onus is on you to make the right choice based on the size of your workload, availability of skilled resources to manage and secure clusters, etc.

### Good: Low Complexity
With its Container-as-a-Service model, you don't have to worry about the underlying infrastructure you need for deploying your container, how you will optimize usage or secure them. Instead, your focus reduces to the four walls of your container - its size, power, and communication with the outside world aka memory, CPU, and networking.

### Good: Better Security
Since you don't have to worry about securing the entire cluster of servers, your security concern is reduced to security within the container, the roles required to run your application, the ports that must be opened for the application that is running inside the container to communicate with the outside world, etc.

### Good: Faster Development

### Good: 
### Bad: Limited Availability
While AWS is rolling out Fargate to as many regions as they can, it is not as available as Lambdas, ECS or EKS.

## Focus of this workshop

In this workshop, we will explore three design patterns viz., the ***Container-on-Demand***, ***Scaling-Container*** and ***Sidecar-Assembly*** patterns that allows Fargate to be used just like Lambdas for heavy on-demand tasks where Lambda is not suitable, or run containers traditionally but without having to manage infrastructure.

We will use the ***Container-on-Demand*** pattern to build an on-demand video thumbnail service to generate thumbnail images from video files. With this pattern, you can spin the containers on demand and immediately decommission after the task is run.

We will use the ***Scaling-Container*** to build an auto-scaling service that finds the value of the coins thrown on a table from an image. With this pattern, you will have a small footprint always running and scale up or down as the processing demands.

Later we will explore the ***Sidecar-Assembly*** pattern to assemble otherwise fully functional services running in containers to build an application that has expanded capabilities beyond what is provided by these services. In essence, to reinforce that the whole is greater than the sum of its parts.

## *Container-on-Demand* Pattern
### Problem
AWS Lambda lets you run functions as a service. This allows you to build applications as a conglomeration of serverless microservices which react to events, eschewing development of core functionalities, easy deployment, automatic scaling and fault tolerance. But Lambda has  many [resource limitations](https://docs.aws.amazon.com/lambda/latest/dg/limits.html). For instance:
-   The default deployment package size is 50 MB.
-   Memory range is from 128 to 3008 MB.
-   Maximum execution timeout for a function is 15 minutes.      
-   Request and response (synchronous calls) body payload size can be up to to 6 MB.
-   Event request (asynchronous calls) body can be up to 128 KB .
These are severe limitations for processing several types of applications including machine learning models where the size of libraries go much above the maximum deployment package size of 250MB or may take longer than 15 minutes to run a batch.

As a result, it is not possible to run large workloads or long running processes on Lambda. Further, the resource limitation around size of the software package restricts the type of workloads your can run on Lambda. For instance, if you have a machine learning model that requires usage of large libraries such as Scikit, Numpy etc, it is impossible to fit the resulting software in a Lambda deployment.

### Solution
Deploy your software package in a container as a Fargate Task. Invoke the task using a Lambda. 

![Container-on-Demand Pattern](https://github.com/skarlekar/fargate-patterns/blob/master/images/container-on-demand-pattern.png)

The entry point in the container can be as trivial as a shell script or could be complex as a web service. But the point to note here is the job submitted to the Fargate Task in this case should be asynchronous. As a result large software packages running large workloads can be run using this pattern.

#### Pattern Components
- 

### Limitations
While using this pattern Fargate puts Lambdas on steroids, Fargate has its [own resource limitations](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_limits.html) due to it serverless nature. For instance, the number of tasks using the Fargate launch type, per region, per account cannot be more than 50 or the maximum container storage for tasks using the Fargate launch type cannot be over 10GB. 

If you think your workloads will breach these limitations, you should seriously consider AWS EMR or AWS Glue for your solution's tech stack.


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEwNTA4MDIwMDksMTMyNzM4NTUyLDE1MD
k1MzA1NzAsMzE5Njc1OTQ0LC04Mzk5MTQyMDQsMTg5MzQxMDY0
NCw4NzQ1NDU0MTcsLTEwNjQ2ODA0MzUsLTE2NTg1NTE5ODksMj
g2MjYzMTQ1LC0xOTQwNDY2NDgxLC0xMjI5OTE1MTEwLDI2MDg0
NDM1NCwtMTc0MzQ2NDQ2OV19
-->