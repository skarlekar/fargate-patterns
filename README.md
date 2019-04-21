# Fargate Design Patterns

## Compendium and Code Examples of AWS Fargate Patterns.

**AWS Fargate** is the Uber of container service allowing engineers to hail a container by specifying their compute and memory needs. By providing incredible on-demand flexibility and removing the burden of resource provisioning just as Lambda did years ago to servers, Fargate is disrupting the container management technology.

## Introduction
Making software behave predictably in different environments where it is deployed during the lifecycle of an application is one of the biggest challenges of development. Subtle differences in system software on which developers have no control - even in same operating systems - can cause unexpected behaviors and are hard to debug and fix. 

Containers were invented to solve this problem. Containers encapsulate entire runtime environments for an application or service including dependent libraries, configurations which are just enough to run the application into software packages that are portable across operating systems. By sandboxing the application into just enough space and opening just the right ports for communication with the outside world, containers also increase the security of an application by reducing blast radius and increasing the number of services that can be run on a unit of hardware.

First released in 2013, Docker introduced the concept of containers. Kubernetes followed in 2014 allowing multiple Docker nodes running on different heterogenous hosts to be orchestrated by automating provisioning, networking, load-balancing, security and scaling across these nodes through a single dashboard or command line. Both of these technologies required the upkeep of the underlying cluster of servers & operating system through upgrades, patching, rehydration, and security management. Amazon introduced ECS and EKS as platform services to streamline this management process for Docker and Kubernetes respectively.

## What is AWS Fargate?

Put simply, **AWS Fargate** is a managed, compute engine provided by AWS to run your containers without having to worry about managing a cluster of servers. You don't have to choose server types, upgrade or patch servers or optimize container packing on your clusters. 

This is analogous to hailing an *Uber* car service. With Uber, you just tell what size car you want based on how many people are riding, if you want a car seat or want the car to be wheel-chair accessible. You don’t specify a Lexus or a Toyota. With Fargate, all you do is package your application in containers, specify the CPU and memory requirements, define networking and IAM policies, and launch the application. Fargate takes care of scaling so that you don't have to worry about provisioning enough compute resources for your containers to scale out or scale them in when they are not utilized.  In essence, Fargate separates the task of running containers from the task of managing the underlying infrastructure. Developers can simply specify the resources that each container requires, and Fargate will handle the rest. ***As a result, applications deployed on Fargate can save you time, manpower, and money***.

If you are used to traditional container management, you will really appreciate Fargate allowing you to focus on the 'Dev' part of designing and building your applications and reduce the 'Ops' part of managing infrastructure from your 'DevOps' responsibilities. 

## Components of AWS Fargate

### Task 
A *Task* is the blue print for your application running on Fargate. You use *Task Definition* to configure your tasks on Fargate and each time you launch a task in Amazon ECS.

The Task Definiton specifies which container repository and container image you want to use for running your Task. It also specifies the CPU, memory, the roles to use for executing the task. 
Fargate then knows which Docker image to use for containers, how many containers to use in the task, and the resource allocation for each container. 

### Service 
Fargate allows you to run and maintain a specified number of instances of a *Task Definition* simultaneously in an Amazon ECS cluster. This is called a *Service*. If any of your tasks should fail or stop for any reason, the Amazon ECS service scheduler launches another instance of your task definition to replace it and maintain the desired count of tasks in the service depending on the scheduling strategy used. 

In addition to maintaining the desired count of tasks in your service, you can optionally run your service behind a load balancer. The load balancer distributes traffic across the tasks that are associated with the service.

### Cluster
An Amazon ECS *Cluster* is a logical grouping of tasks or services. Clusters are AWS region specific and can contain tasks using both the Fargate and EC2 launch types.

## AWS Fargate - the Good, Bad & Ugly
###  Good & Bad: Pay Per Use
Fargate is a good choice if you are leaving a lot of compute power and memory foot-print unused. Unlike ECS or EKS, you only pay for the compute and memory that you actually use. It also integrates well with other AWS services allowing you to schedule tasks and run them based on events while automatically fading them out when not in use.

While Fargate provides you an opportunity to cut costs by charging you only for the time your container is running, the average per-hour cost for running Fargate is more than the per-hour cost of running ECS or EKS in spite of [major price reduction in Jan 2019](https://aws.amazon.com/blogs/compute/aws-fargate-price-reduction-up-to-50/) proving once again that there is no free lunch. The cost differential is the price you pay for not having to deal with the complexity of managing infrastructure or investing in time and resources to deal with the cluster management that comes with the traditional solutions. 

As a result, the onus is on you to make the right choice based on the size of your workload, availability of skilled resources to manage and secure clusters, etc.

### Good: Low Complexity
With its Container-as-a-Service model, you don't have to worry about the underlying infrastructure you need for deploying your container, how you will optimize usage or secure them. Instead, your focus reduces to the four walls of your container - its size, power, and communication with the outside world aka memory, CPU, and networking.

### Good: Better Security
Since you don't have to worry about securing the entire cluster of servers, your security concern is reduced to security within the container, the roles required to run your application, the ports that must be opened for the application that is running inside the container to communicate with the outside world, etc.

### Good: Faster Development
As the problems of systems management is alleviated, developers spend less time on operational issues and can focus on solving business problems building services.

### Good:  Scaling
As Fargate is serverless, scaling is taken care by the provider seamlessly. As a result, you do not have to consider the number of concurrent requests you can handle. Having said that, if you integrate Fargate with downstream *server-based* solutions, you should expect a increase in load on those components when your services running on Fargate scales out significantly.

### Bad: Limited Availability
While AWS is rolling out Fargate to as many regions as they can, it is not as available as Lambdas, ECS or EKS. As of April 2019, Fargate is not available in GovCloud, Sao Paulo, Paris, Stockholm, Japan and China.

## Focus of these Behavioral Patterns
Behavioral patterns provide solution for the better interaction between objects and how to provide lose coupling and flexibility to extend easily.

In this section, we will explore three behavioral design patterns viz., the ***Container-on-Demand***, ***Scaling-Container*** and ***Sidecar-Assembly*** patterns that allows Fargate to be used just like Lambdas for heavy on-demand tasks where Lambda is not suitable, or run containers traditionally but without having to manage infrastructure. 

We will use the ***Container-on-Demand*** pattern to build an on-demand video thumbnail service to generate thumbnail images from video files. With this pattern, you can spin the containers on demand and immediately decommission after the task is run.

We will use the ***Scaling-Container*** to build an auto-scaling service that finds the value of the coins thrown on a table from an image. With this pattern, you will have a small footprint always running and scale up or down as the processing demands.

Later we will explore the ***Sidecar-Assembly*** pattern to assemble otherwise fully functional services running in containers to build an application that has expanded capabilities beyond what is provided by these services. In essence, to reinforce that the whole is greater than the sum of its parts.

## *Container-on-Demand* Pattern
### Problem
AWS Lambda lets you run functions as a service. This allows you to build applications as a conglomeration of serverless microservices which react to events, eschewing development of core functionalities, easy deployment, automatic scaling and fault tolerance. But Lambda has  many [resource limitations](https://docs.aws.amazon.com/lambda/latest/dg/limits.html) and in general, it is not efficient for running long-running jobs. 

For instance these are current limitations on Lambda (as of April 2019):
-   The default deployment package size is 50 MB.
-   Memory range is from 128 to 3008 MB.
-   Maximum execution timeout for a function is 15 minutes.      
-   Request and response (synchronous calls) body payload size can be up to to 6 MB.
-   Event request (asynchronous calls) body can be up to 128 KB .

These are severe limitations for processing several types of applications including machine learning models where the size of libraries go much above the maximum deployment package size of 250MB or may take longer than 15 minutes to run a batch.

As a result, it is not possible to run large workloads or long running processes on Lambda. Further, the resource limitation around size of the software package restricts the type of workloads your can run on Lambda. For instance, if you have a machine learning model that requires usage of large libraries such as Scikit, Numpy etc, it is impossible to fit the software package in a Lambda deployment.

### Solution
Deploy your software package in a container as a Fargate Task. Invoke the task using a Lambda. The Fargate Task is started from a dormant state. Once the process is complete and the output written to the output repository, the Task is automatically stopped. As a result of this, you pay only for the time the Task is running. Additionally, you can preconfigure the size of the task (vCPU, memory, environment variables to pass parameters to the job) or override it for every invocation.

![Container-on-Demand Pattern](https://github.com/skarlekar/fargate-patterns/blob/master/images/container-on-demand-pattern.png)

The entry point in the container can be as trivial as a shell script or could be complex as a web service. But the point to note here is the job submitted to the Fargate Task in this case should be asynchronous. As a result large software packages running large workloads can be run using this pattern.

#### Pattern Components
- **Input Repository** - The input for your *Processor* is stored here and should be reachable by the processor. This could be S3-based object store or a data base. Ideally, this repository should notify the task invoker when a new object is uploaded or updated.
- **Task Invoker** - A short-running function that is used to invoke your Processor. This could be a Lambda function or a synchronous service running as part of another larger process chain.
- **Processor** - A long-running task that is the core of the pattern. It is invoked by the Task Invoker. This could be a Fargate Task that reads its input from the Input Repository, processes it and writes back the output to the Output Repository.
- **Output Repository** - Results of the Fargate Task are stored here. Again, this could be a S3 store or a database and could be optionally configure to emit events on inserts and updates.

### Limitations
While using this pattern Fargate puts Lambdas on steroids, Fargate has its [own resource limitations](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_limits.html) due to it serverless nature. For instance, the number of tasks using the Fargate launch type, per region, per account cannot be more than 50 or the maximum container storage for tasks using the Fargate launch type cannot be over 10GB. 

If you think your workloads will breach these limitations, you should seriously consider AWS EMR or AWS Glue for your solution's tech stack.

## Scaling Container Pattern
### Problem
In the [problem](https://github.com/skarlekar/fargate-patterns#problem) section of the [Container-on-Demand](https://github.com/skarlekar/fargate-patterns#container-on-demand-pattern) pattern we discussed how the limitations on long-processes rules out Lambda for such asynchronous workloads. Here the main problem is the restrictions on the time it takes to run the jobs which cannot exceed 15 minutes. While the Container-on-Demand pattern solves this issue, for synchronous web services that execute within these limits, the main limitations are the ***size of the deployment package***, networking, local temporary store or the language supported in Lambda. 

As of this writing in April 2019, AWS Lambda natively supports Java, Go, PowerShell, Node.js, C#, Python, and Ruby code. Most recently AWS Lambda provides a Runtime API which allows you to use any additional programming languages to author your functions. While the concept of allowing you to bring your own runtime is radical, it is not straight forward as can be seen from this author's experiment [here](https://github.com/skarlekar/lambda-custom-runtime).

***How do we run synchronous services where the size of the deployment package exceeds the Lambda limits?*** 

While Lambda Layers mitigate some of this issue by allowing artifacts to be shared between Lambdas, it introduces it [own set of issues](https://lumigo.io/blog/lambda-layers-when-to-use-it/), especially around testing Lambdas locally and layers still count towards the 250MB hard limit on the unzipped deployment package size.

***What if you want to run an always-on services that can scale on-demand?*** 

Note that, the Container-on-Demand pattern spins up task to execute the job and spins it down. For asynchronous workloads the time taken to spin-up is not an issue. But for synchronous web services, time is dear. 

### Solution
Following is a possible solution to use a Fargate Service fronted by an Application Load Balancer.

- Deploy your service in a Fargate Task
- Open ports for two-way communication in the Task and Container
- Create an ECS Service to wrap around the Fargate Task. 
- Attach an Application Load Balancer in front of the Fargate Service .
- Register an auto-scaling target with rules on when to scale out your service and when to scale it in.

![enter image description here](https://github.com/skarlekar/fargate-patterns/blob/master/images/scaling-container-pattern.png) 



<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEyNDAyNTU0OTIsMjAyMjYxNjU4NSwtOD
E5Njk1MzE0LDE1NzQ4MDI0MjEsMTM5MTIxNTIyNCwtMTE3Mjc5
ODgyOSwtNDk3NDM4NTAwLC05ODYzMTU1MDUsMTU2NjAzNjA4NC
w3MTA1MjUwNyw0NjY5MjkzODcsLTE2NDc0MDQ4MjAsMTMyNzM4
NTUyLDE1MDk1MzA1NzAsMzE5Njc1OTQ0LC04Mzk5MTQyMDQsMT
g5MzQxMDY0NCw4NzQ1NDU0MTcsLTEwNjQ2ODA0MzUsLTE2NTg1
NTE5ODldfQ==
-->