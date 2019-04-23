# Fargate Patterns
## Table of Contents

*   [Compendium and Code Examples of AWS Fargate Patterns.][1]
*   [Introduction][2]
*   [What is AWS Fargate?][3]
*   [Components of AWS Fargate][4] 
    *   [Task][5]
    *   [Service][6]
    *   [Cluster][7]
*   [AWS Fargate - the Good, Bad & Ugly][8] 
    *   [Good & Bad: Pay Per Use][9]
    *   [Good: Low Complexity][10]
    *   [Good: Better Security][11]
    *   [Good: Faster Development][12]
    *   [Good: Scaling][13]
    *   [Bad: Limited Availability][14]
*   [Behavioral Design Patterns for AWS Fargate][15]
*   [Container-on-Demand Pattern][16] 
    *   [Context & Problem][17]
    *   [Solution][18]
    *   [Pattern Components][19]
    *   [Limitations][20]
    *   [Container-on-Demand Pattern - Example][21]
    *   [Tom Thumb - A Video Thumbnail Generator Task][22]
    *   [Code Repository][23]
*   [Scaling Container Pattern][24] 
    *   [Context & Problem][25]
    *   [Solution][26]
    *   [Pattern Components][27]
    *   [Scaling Container Pattern - Example][28]
    *   [Bean-counter - A Coin-counter Service][29]
    *   [Code Repository][30]
*   [Sidecar Assembly Pattern][31] 
    *   [Problem][32]
    *   [Solution][33]
*   [Conclusion][34] 
    *   [Scenarios where Fargate is most Beneficial][35]
    *   [Scenarios where Fargate may not be the Best Choice][36]

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Compendium and Code Examples of AWS Fargate Patterns.

**AWS Fargate** is the Uber of container service allowing engineers to hail a container by specifying their compute and memory needs. By providing incredible on-demand flexibility and removing the burden of resource provisioning just as Lambda did years ago to servers, Fargate is disrupting the container management technology.

## Introduction

Making software behave predictably in different environments where it is deployed during the lifecycle of an application is one of the biggest challenges of development. Subtle differences in system software on which developers have no control - even in same operating systems - can cause unexpected behaviors and are hard to debug and fix.

Containers were invented to solve this problem. Containers encapsulate entire runtime environments for an application or service including dependent libraries, configurations which are just enough to run the application into software packages that are portable across operating systems. By sandboxing the application into just enough space and opening just the right ports for communication with the outside world, containers also increase the security of an application by reducing blast radius and increasing the number of services that can be run on a unit of hardware.

First released in 2013, Docker introduced the concept of containers. Kubernetes followed in 2014 allowing multiple Docker nodes running on different heterogenous hosts to be orchestrated by automating provisioning, networking, load-balancing, security and scaling across these nodes through a single dashboard or command line. Both of these technologies required the upkeep of the underlying cluster of servers & operating system through upgrades, patching, rehydration, and security management. Amazon introduced ECS and EKS as platform services to streamline this management process for Docker and Kubernetes respectively.

## What is AWS Fargate?

Put simply, **AWS Fargate** is a managed, compute engine provided by AWS to run your containers without having to worry about managing a cluster of servers. You don't have to choose server types, upgrade or patch servers or optimize container packing on your clusters.

This is analogous to hailing an *Uber* car service. With Uber, you just tell what size car you want based on how many people are riding, if you want a car seat or want the car to be wheel-chair accessible. You don’t specify a Lexus or a Toyota. With Fargate, all you do is package your application in containers, specify the CPU and memory requirements, define networking and IAM policies, and launch the application. Fargate takes care of scaling so that you don't have to worry about provisioning enough compute resources for your containers to scale out or scale them in when they are not utilized. In essence, Fargate separates the task of running containers from the task of managing the underlying infrastructure. Developers can simply specify the resources that each container requires, and Fargate will handle the rest. ***As a result, applications deployed on Fargate can save you time, manpower, and money***.

If you are used to traditional container management, you will really appreciate Fargate allowing you to focus on the 'Dev' part of designing and building your applications and reduce the 'Ops' part of managing infrastructure from your 'DevOps' responsibilities.

## Components of AWS Fargate

[caption id="attachment_494" align="aligncenter" width="840"][<img src="http://srini.karlekar.com/wp-content/uploads/2019/04/Fargate-Components-1024x607.png" alt="Fargate Components" width="840" height="498" class="size-large wp-image-494" />][37] Fargate Components[/caption]

### Task

A *Task* is the blueprint for your application running on Fargate. You use *Task Definition* to configure your tasks on Fargate and each time you launch a task in Amazon ECS.

The Task Definition specifies which container repository and container image you want to use for running your Task. It also specifies the CPU, memory, the roles to use for executing the task. Fargate then knows which Docker image to use for containers, how many containers to use in the task and the resource allocation for each container.

### Service

Fargate allows you to run and maintain a specified number of instances of a *Task Definition* simultaneously in an Amazon ECS cluster. This is called a *Service*. If any of your tasks should fail or stop for any reason, the Amazon ECS service scheduler launches another instance of your task definition to replace it and maintain the desired count of tasks in the service depending on the scheduling strategy used.

In addition to maintaining the desired count of tasks in your service, you can optionally run your service behind a load balancer. The load balancer distributes traffic across the tasks that are associated with the service.

### Cluster

An Amazon ECS *Cluster* is a logical grouping of tasks or services. Clusters are AWS region specific and can contain tasks using both the Fargate and EC2 launch types.

## AWS Fargate - the Good, Bad & Ugly

### Good & Bad: Pay Per Use

Fargate is a good choice if you are leaving a lot of computing power and memory foot-print unused. Unlike ECS or EKS, you only pay for the compute and memory that you actually use. It also integrates well with other AWS services allowing you to schedule tasks and run them based on events while automatically fading them out when not in use.

While Fargate provides you an opportunity to cut costs by charging you only for the time your container is running, the average per-hour cost for running Fargate is more than the per-hour cost of running ECS or EKS in spite of [major price reduction in Jan 2019][38] proving once again that there is no free lunch. The cost differential is the price you pay for not having to deal with the complexity of managing infrastructure or investing in time and resources to deal with the cluster management that comes with the traditional solutions.

As a result, the onus is on you to make the right choice based on the size of your workload, availability of skilled resources to manage and secure clusters, etc.

### Good: Low Complexity

With its Container-as-a-Service model, you don't have to worry about the underlying infrastructure you need for deploying your container, how you will optimize usage or secure them. Instead, your focus reduces to the four walls of your container - its size, power, and communication with the outside world aka memory, CPU, and networking.

### Good: Better Security

Since you don't have to worry about securing the entire cluster of servers, your security concern is reduced to security within the container, the roles required to run your application, the ports that must be opened for the application that is running inside the container to communicate with the outside world, etc.

### Good: Faster Development

As the problems of systems management are alleviated, developers spend less time on operational issues and can focus on solving business problems building services.

### Good: Scaling

As Fargate is serverless, scaling is taken care of by the provider seamlessly. As a result, you do not have to consider the number of concurrent requests you can handle. Having said that, if you integrate Fargate with downstream *server-based* solutions, you should expect an increase in load on those components when your services running on Fargate scales out significantly.

### Bad: Limited Availability

While AWS is rolling out Fargate to as many regions as they can, it is not as available as Lambdas, ECS or EKS. As of April 2019, Fargate is not available in GovCloud, Sao Paulo, Paris, Stockholm, Japan, and China.

## Behavioral Design Patterns for AWS Fargate

Behavioral patterns provide a solution for the better interaction between components and foster lose coupling while providing the flexibility to extend these components easily independent of each other.

In this section, we will explore three behavioral design patterns for AWS Fargate viz., the ***Container-on-Demand***, ***Scaling-Container*** and ***Sidecar-Assembly*** patterns that allows Fargate to be used just like Lambdas for heavy on-demand tasks where Lambda is not suitable, or allow you to run containers traditionally but without having to manage infrastructure. Additionally, we will explore how to attach sidecar containers to a parent container to provide supporting features for the application.

We will use the ***Container-on-Demand*** pattern to build an on-demand video thumbnail service to generate thumbnail images from video files. With this pattern, you can spin the containers on demand and immediately decommission after the task is run.

We will use the ***Scaling-Container*** to build an auto-scaling service that finds the value of the coins thrown on a table from an image. With this pattern, you will have a small footprint always running and scale up or down as the processing demands.

Later we will explore the ***Sidecar-Assembly*** pattern to deploy components of an application into a separate container to provide isolation and encapsulation.

## Container-on-Demand Pattern

### Context & Problem

AWS Lambda lets you run functions as a service. This allows you to build applications as a conglomeration of serverless microservices which react to events, eschewing development of core functionalities, easy deployment, automatic scaling and fault tolerance. But Lambda has many [resource limitations][39] and in general, it is not efficient for running long-running jobs.

For instance, these are current limitations on Lambda (as of April 2019): - The default deployment package size is 50 MB. - Memory range is from 128 to 3008 MB. - Maximum execution timeout for a function is 15 minutes.  
- Request and response (synchronous calls) body payload size can be up to to 6 MB. - Event request (asynchronous calls) body can be up to 128 KB.

These are severe limitations for processing several types of applications including machine learning models where the size of libraries go much above the maximum deployment package size of 250MB or may take longer than 15 minutes to run a batch.

As a result, it is not possible to run large workloads or long running processes on Lambda. Further, the resource limitation around the size of the software package restricts the type of workloads you can run on Lambda. For instance, if you have a machine learning model that requires the usage of large libraries such as Scikit, Numpy, etc, it is impossible to fit the software package in a Lambda deployment.

### Solution

Deploy your software package in a container as a Fargate Task. Invoke the task using a Lambda. The Fargate Task is started from a dormant state. Once the process is complete and the output is written to the output repository, the Task is automatically stopped. As a result of this, you pay only for the time the Task is running. Additionally, you can preconfigure the size of the task (vCPU, memory, environment variables to pass parameters to the job) or override it for every invocation.

[caption id="attachment_490" align="aligncenter" width="840"][<img src="http://srini.karlekar.com/wp-content/uploads/2019/04/container-on-demand-pattern-1024x607.png" alt="Container on Demand Pattern" width="840" height="498" class="size-large wp-image-490" />][40] Container on Demand Pattern[/caption]

The entry point in the container can be as trivial as a shell script or could be complex as a web service. But the point to note here is the job submitted to the Fargate Task, in this case, should be asynchronous. As a result, large software packages running large workloads can be run using this pattern.

#### Pattern Components

*   **Input Repository** - The input for your *Processor* is stored here and should be reachable by the processor. This could be an S3-based object store or a database. Ideally, this repository should notify the task invoker when a new object is uploaded or updated.
*   **Task Invoker** - A short-running function that is used to invoke your Processor. This could be a Lambda function or a synchronous service running as part of another larger process chain.
*   **Processor** - A long-running task that is the core of the pattern. It is invoked by the Task Invoker. This could be a Fargate Task that reads its input from the Input Repository, processes it and writes back the output to the Output Repository. The Fargate task can be configured to use one or more containers (with a maximum of 10).
*   **Output Repository** - Results of the Fargate Task are stored here. Again, this could be an S3 store or a database and could be optionally configured to emit events on inserts and updates.

### Limitations

While using this pattern Fargate puts Lambdas on steroids, Fargate has its [own resource limitations][41] due to its serverless nature. For instance, the number of tasks using the Fargate launch type, per region, per account cannot be more than 50 or the maximum container storage for tasks using the Fargate launch type cannot be over 10GB.

If you think your workloads will breach these limitations, you should seriously consider AWS EMR or AWS Glue for your solution's tech stack.

### Container-on-Demand Pattern - Example

#### Tom Thumb - A Video Thumbnail Generator Task

Tom Thumb is a video thumbnail generator task. It is implemented following the Container-on-Demand pattern. In typical usage, a user uploads a video file to an S3 bucket. A trigger is set on the S3 bucket to notify a Lambda function in the event of a file upload to the video folder in the bucket. The Lambda is deployed with a Python code to extract the name of the video file from the Lambda notification event and invoke a Fargate task. The Fargate task consists of one container that uses FFmpeg application to decode the video and freeze an image at a given position in the video. The frozen image is written to a pre-configured folder in an S3 bucket.

#### Code Repository

All code examples, prerequisites, and instructions are available in the companion [Git][42] at [tom-thumb][43] subproject.

## Scaling Container Pattern

### Context & Problem

In the [problem][44] section of the [Container-on-Demand][45] pattern we discussed how the limitations on long-running processes rule out Lambda for asynchronous workloads. Therefore, we use the Container-on-Demand pattern to overcome the time limitation of Lambda which cannot exceed 15 minutes.

While the Container-on-Demand pattern solves this issue, for synchronous web services that execute within these limits, the main limitations are the ***size of the deployment package***, networking, or the language supported in Lambda.

As of this writing in April 2019, AWS Lambda natively supports Java, Go, PowerShell, Node.js, C#, Python, and Ruby code. Most recently AWS Lambda provides a Runtime API which allows you to use any additional programming languages to author your functions. While the concept of allowing you to bring your own runtime is radical, it is not straight forward as can be seen from this author's experiment [here][46].

***How do we run synchronous services where the size of the deployment package exceeds the Lambda limits?***

While Lambda Layers mitigate some of this issue by allowing artifacts to be shared between Lambdas, it introduces it [own set of issues][47], especially around testing Lambdas locally and layers still count towards the 250MB hard limit on the unzipped deployment package size.

***What if you want to run always-on services that can scale on-demand?***

Note that, the Container-on-Demand pattern spins up a task to execute the job and spins it down. For asynchronous workloads, the time taken to spin-up is not an issue. But for synchronous web services, time is dear.

### Solution

Following is a possible solution to use a Fargate Service fronted by an Application Load Balancer.

*   Deploy your service in a Fargate Task
*   Open ports for two-way communication in the Task and Container
*   Create an ECS Service to wrap around the Fargate Task. 
*   Attach an Application Load Balancer in front of the Fargate Service.
*   Register an auto-scaling target with rules on when to scale out your service and when to scale it in.

[caption id="attachment_501" align="aligncenter" width="840"][<img src="http://srini.karlekar.com/wp-content/uploads/2019/04/scaling-container-pattern-1024x607.png" alt="Scaling Container Pattern" width="840" height="498" class="size-large wp-image-501" />][48] Scaling Container Pattern[/caption]

#### Pattern Components

*   **Fargate Task** - A Fargate task that has its ports open for two-way communication using one or more containers (within a maximum limit of ten containers).
*   **ECS Service** - An ECS service that uses the Fargate Task from above identifying the desired count of tasks that must be run at any given time.
*   **Application Load Balancer** - An Application Load Balancer with a listener to forward requests to the ECS Service.
*   **API Gateway** - An *optional* API gateway configured to forward requests to the application load balancer.
*   **Web Interface** - An *optional* browser-based interface for allowing users to post requests to the service. This could be a simple HTML form.

### Scaling Container Pattern - Example

#### Bean-counter - A Coin-counter Service

Bean Counter is a coin counter service. It will analyze an image of coins and return the total value of the coins in the image. It works only on US Mint issued coined and does not recognize any denomination above a quarter dollar coin. It also assumes that the picture contains a quarter. The quarter is used to calibrate the size of the coins. It is implemented following the Scaling-Container pattern. In typical usage, a user navigates to the URL of the ALB on the browser and enters the URL for the service along with the location of the image file containing the picture of the coins. The Bean-Counter service then invokes the Fargate Task and returns the response to the browser.

#### Code Repository

All code examples, prerequisites and instructions are available in the companion [Git][42] at [bean-counter][49] subproject.

## Sidecar Assembly Pattern

### Problem

Services require orthogonal technical capabilities, such as monitoring, logging, configuration, and networking services. While the components encapsulating these orthogonal capabilities can be integrated into the main service, it will leave the main service exposed to the vagaries of these components. For instance, they will not be well isolated, and an outage in one of these components can affect other components or the entire service. Also, they usually need to be implemented using the same language as the parent service. As a result, the component and the main service have close interdependence on each other.

One option is to deploy these orthogonal components as separate services allowing each component to have its own life-cycle and be built using different languages. While this gives more flexibility, deploying these features as separate services can add latency to the application.

### Solution

Co-deploy the orthogonal components along with the main service by placing them in their own containers. Containers in a task are co-deployed together in the same host thereby not affecting the latency of the service significantly for the communication between them. As a result of this co-deployment, the sidecar and the main service can access the same resources. This allows the sidecar to monitor system resources used by both the sidecar and the primary service.

[caption id="attachment_503" align="aligncenter" width="759"][<img src="http://srini.karlekar.com/wp-content/uploads/2019/04/side-car-assembly.png" alt="Side Car Assembly Pattern" width="759" height="492" class="size-full wp-image-503" />][50] Side Car Assembly Pattern[/caption]

This pattern can also enable applications to be composed of heterogeneous components and services that have expanded capabilities beyond what is provided by these individual services. In essence, to reinforce that the whole is greater than the sum of its parts. The sidecar also shares the same lifecycle as the parent application, is created and retired alongside the parent.

## Conclusion

Each application is unique and solving different needs based on business requirements. If the task of infrastructure management is too onerous and/or if you only want to pay for your computing time, then Fargate may be the right choice for you.

On the other hand, if you need greater control of the network resources or have large container workloads with consistent demand throughout the day, then it warrants maintaining a cluster of servers to run ECS or EKS. With the latter choice, you can use reserved or spot instances to offset your cost.

### Scenarios where Fargate is most Beneficial

Fargate can be used with any type of containerized application. However, this doesn’t mean that you will get the same benefit in every scenario. Fargate would be most beneficial for projects that need to reduce the time from ideation to realization such as proofs-of-concept and well-designed, decoupled, micro service-based architectures deployed in production environments.

**Applications can consist of a mix of Fargate & Lambda to exploit the Serverless model.**

Use Lambdas for small & tight services with low memory (<3GB) and small request-response cycles (<15 mins).

Use containers deployed on Fargate for: - Existing legacy services that cannot be trivially refactored, - Applications are written in languages not supported by Lambda, - Need to use large libraries that cannot fit into a Lambda profile (Quantlib, Scikit, etc), - Where you need more control over networking, compute horsepower or memory - Use cases that require a long in-process runtime.

### Scenarios where Fargate may not be the Best Choice

*   When you require greater control of your EC2 instances to support networking, COTS applications that require broader customization options, then use ECS without Fargate.
*   When you want fast request-response cycle time then Lambda may be a good choice. This is especially true if you are using large container images written with object-heavy languages such as Java/Scala that requires significant initiation time to start the JVM and bootstrap objects. 
*   By breaking down your application into smaller modules that fit into Lambdas and using Layers and Step Functions you can reap the benefits of Serverless architectures while paying only for your compute time.

 [1]: #compendium-and-code-examples-of-aws-fargate-patterns
 [2]: #introduction
 [3]: #what-is-aws-fargate-
 [4]: #components-of-aws-fargate
 [5]: #task
 [6]: #service
 [7]: #cluster
 [8]: #aws-fargate---the-good--bad---ugly
 [9]: #good---bad--pay-per-use
 [10]: #good--low-complexity
 [11]: #good--better-security
 [12]: #good--faster-development
 [13]: #good---scaling
 [14]: #bad--limited-availability
 [15]: #behavioral-design-patterns-for-aws-fargate
 [16]: #container-on-demand-pattern
 [17]: #context---problem
 [18]: #solution
 [19]: #pattern-components
 [20]: #limitations
 [21]: #container-on-demand-pattern---example
 [22]: #tom-thumb---a-video-thumbnail-generator-task
 [23]: #code-repository
 [24]: #scaling-container-pattern
 [25]: #context---problem-1
 [26]: #solution-1
 [27]: #pattern-components-1
 [28]: #scaling-container-pattern---example
 [29]: #bean-counter---a-coin-counter-service
 [30]: #code-repository-1
 [31]: #sidecar-assembly-pattern
 [32]: #problem
 [33]: #solution-2
 [34]: #conclusion
 [35]: #scenarios-where-fargate-is-most-beneficial
 [36]: #scenarios-where-fargate-may-not-be-the-best-choice
 [37]: http://srini.karlekar.com/wp-content/uploads/2019/04/Fargate-Components.png
 [38]: https://aws.amazon.com/blogs/compute/aws-fargate-price-reduction-up-to-50/
 [39]: https://docs.aws.amazon.com/lambda/latest/dg/limits.html
 [40]: http://srini.karlekar.com/wp-content/uploads/2019/04/container-on-demand-pattern.png
 [41]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_limits.html
 [42]: http://bit.ly/fargatepatterns
 [43]: http://bit.ly/tom-thumb
 [44]: https://github.com/skarlekar/fargate-patterns#problem
 [45]: https://github.com/skarlekar/fargate-patterns#container-on-demand-pattern
 [46]: https://github.com/skarlekar/lambda-custom-runtime
 [47]: https://lumigo.io/blog/lambda-layers-when-to-use-it/
 [48]: http://srini.karlekar.com/wp-content/uploads/2019/04/scaling-container-pattern.png
 [49]: http://bit.ly/bean-counter
 [50]: http://srini.karlekar.com/wp-content/uploads/2019/04/side-car-assembly.png
