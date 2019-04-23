<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>blog_html</title>
  <link rel="stylesheet" href="https://stackedit.io/style.css" />
</head>

<body class="stackedit">
  <div class="stackedit__left">
    <div class="stackedit__toc">
      
<ul>
<li><a href="#fargate-design-patterns">Fargate Design Patterns</a>
<ul>
<li><a href="#compendium-and-code-examples-of-aws-fargate-patterns.">Compendium and Code Examples of AWS Fargate Patterns.</a></li>
<li><a href="#introduction">Introduction</a></li>
<li><a href="#what-is-aws-fargate">What is AWS Fargate?</a></li>
<li><a href="#components-of-aws-fargate">Components of AWS Fargate</a></li>
<li><a href="#aws-fargate---the-good-bad--ugly">AWS Fargate - the Good, Bad & Ugly</a></li>
<li><a href="#behavioral-design-patterns-for-aws-fargate">Behavioral Design Patterns for AWS Fargate</a></li>
<li><a href="#container-on-demand-pattern">Container-on-Demand Pattern</a></li>
<li><a href="#scaling-container-pattern">Scaling Container Pattern</a></li>
<li><a href="#sidecar-assembly-pattern">Sidecar Assembly Pattern</a></li>
<li><a href="#instructions-for-running-the-examples">Instructions for Running the Examples</a></li>
<li><a href="#examples">Examples</a></li>
<li><a href="#conclusion">Conclusion</a></li>
</ul>
</li>
</ul>

    </div>
  </div>
  <div class="stackedit__right">
    <div class="stackedit__html">
      <h1 id="fargate-design-patterns">Fargate Design Patterns</h1>
<h2 id="compendium-and-code-examples-of-aws-fargate-patterns.">Compendium and Code Examples of AWS Fargate Patterns.</h2>
<p><strong>AWS Fargate</strong> is the Uber of container service allowing engineers to hail a container by specifying their compute and memory needs. By providing incredible on-demand flexibility and removing the burden of resource provisioning just as Lambda did years ago to servers, Fargate is disrupting the container management technology.</p>
<h2 id="introduction">Introduction</h2>
<p>Making software behave predictably in different environments where it is deployed during the lifecycle of an application is one of the biggest challenges of development. Subtle differences in system software on which developers have no control - even in same operating systems - can cause unexpected behaviors and are hard to debug and fix.</p>
<p>Containers were invented to solve this problem. Containers encapsulate entire runtime environments for an application or service including dependent libraries, configurations which are just enough to run the application into software packages that are portable across operating systems. By sandboxing the application into just enough space and opening just the right ports for communication with the outside world, containers also increase the security of an application by reducing blast radius and increasing the number of services that can be run on a unit of hardware.</p>
<p>First released in 2013, Docker introduced the concept of containers. Kubernetes followed in 2014 allowing multiple Docker nodes running on different heterogenous hosts to be orchestrated by automating provisioning, networking, load-balancing, security and scaling across these nodes through a single dashboard or command line. Both of these technologies required the upkeep of the underlying cluster of servers &amp; operating system through upgrades, patching, rehydration, and security management. Amazon introduced ECS and EKS as platform services to streamline this management process for Docker and Kubernetes respectively.</p>
<h2 id="what-is-aws-fargate">What is AWS Fargate?</h2>
<p>Put simply, <strong>AWS Fargate</strong> is a managed, compute engine provided by AWS to run your containers without having to worry about managing a cluster of servers. You don’t have to choose server types, upgrade or patch servers or optimize container packing on your clusters.</p>
<p>This is analogous to hailing an <em>Uber</em> car service. With Uber, you just tell what size car you want based on how many people are riding, if you want a car seat or want the car to be wheel-chair accessible. You don’t specify a Lexus or a Toyota. With Fargate, all you do is package your application in containers, specify the CPU and memory requirements, define networking and IAM policies, and launch the application. Fargate takes care of scaling so that you don’t have to worry about provisioning enough compute resources for your containers to scale out or scale them in when they are not utilized.  In essence, Fargate separates the task of running containers from the task of managing the underlying infrastructure. Developers can simply specify the resources that each container requires, and Fargate will handle the rest. <em><strong>As a result, applications deployed on Fargate can save you time, manpower, and money</strong></em>.</p>
<p>If you are used to traditional container management, you will really appreciate Fargate allowing you to focus on the ‘Dev’ part of designing and building your applications and reduce the ‘Ops’ part of managing infrastructure from your ‘DevOps’ responsibilities.</p>
<h2 id="components-of-aws-fargate">Components of AWS Fargate</h2>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/Fargate%20Components.png" alt="enter image description here"></p>
<h3 id="task">Task</h3>
<p>A <em>Task</em> is the blueprint for your application running on Fargate. You use <em>Task Definition</em> to configure your tasks on Fargate and each time you launch a task in Amazon ECS.</p>
<p>The Task Definition specifies which container repository and container image you want to use for running your Task. It also specifies the CPU, memory, the roles to use for executing the task.<br>
Fargate then knows which Docker image to use for containers, how many containers to use in the task and the resource allocation for each container.</p>
<h3 id="service">Service</h3>
<p>Fargate allows you to run and maintain a specified number of instances of a <em>Task Definition</em> simultaneously in an Amazon ECS cluster. This is called a <em>Service</em>. If any of your tasks should fail or stop for any reason, the Amazon ECS service scheduler launches another instance of your task definition to replace it and maintain the desired count of tasks in the service depending on the scheduling strategy used.</p>
<p>In addition to maintaining the desired count of tasks in your service, you can optionally run your service behind a load balancer. The load balancer distributes traffic across the tasks that are associated with the service.</p>
<h3 id="cluster">Cluster</h3>
<p>An Amazon ECS <em>Cluster</em> is a logical grouping of tasks or services. Clusters are AWS region specific and can contain tasks using both the Fargate and EC2 launch types.</p>
<h2 id="aws-fargate---the-good-bad--ugly">AWS Fargate - the Good, Bad &amp; Ugly</h2>
<h3 id="good--bad-pay-per-use">Good &amp; Bad: Pay Per Use</h3>
<p>Fargate is a good choice if you are leaving a lot of computing power and memory foot-print unused. Unlike ECS or EKS, you only pay for the compute and memory that you actually use. It also integrates well with other AWS services allowing you to schedule tasks and run them based on events while automatically fading them out when not in use.</p>
<p>While Fargate provides you an opportunity to cut costs by charging you only for the time your container is running, the average per-hour cost for running Fargate is more than the per-hour cost of running ECS or EKS in spite of <a href="https://aws.amazon.com/blogs/compute/aws-fargate-price-reduction-up-to-50/">major price reduction in Jan 2019</a> proving once again that there is no free lunch. The cost differential is the price you pay for not having to deal with the complexity of managing infrastructure or investing in time and resources to deal with the cluster management that comes with the traditional solutions.</p>
<p>As a result, the onus is on you to make the right choice based on the size of your workload, availability of skilled resources to manage and secure clusters, etc.</p>
<h3 id="good-low-complexity">Good: Low Complexity</h3>
<p>With its Container-as-a-Service model, you don’t have to worry about the underlying infrastructure you need for deploying your container, how you will optimize usage or secure them. Instead, your focus reduces to the four walls of your container - its size, power, and communication with the outside world aka memory, CPU, and networking.</p>
<h3 id="good-better-security">Good: Better Security</h3>
<p>Since you don’t have to worry about securing the entire cluster of servers, your security concern is reduced to security within the container, the roles required to run your application, the ports that must be opened for the application that is running inside the container to communicate with the outside world, etc.</p>
<h3 id="good-faster-development">Good: Faster Development</h3>
<p>As the problems of systems management are alleviated, developers spend less time on operational issues and can focus on solving business problems building services.</p>
<h3 id="good--scaling">Good:  Scaling</h3>
<p>As Fargate is serverless, scaling is taken care of by the provider seamlessly. As a result, you do not have to consider the number of concurrent requests you can handle. Having said that, if you integrate Fargate with downstream <em>server-based</em> solutions, you should expect an increase in load on those components when your services running on Fargate scales out significantly.</p>
<h3 id="bad-limited-availability">Bad: Limited Availability</h3>
<p>While AWS is rolling out Fargate to as many regions as they can, it is not as available as Lambdas, ECS or EKS. As of April 2019, Fargate is not available in GovCloud, Sao Paulo, Paris, Stockholm, Japan, and China.</p>
<h2 id="behavioral-design-patterns-for-aws-fargate">Behavioral Design Patterns for AWS Fargate</h2>
<p>Behavioral patterns provide a solution for the better interaction between components and foster lose coupling while providing the flexibility to extend these components easily independent of each other.</p>
<p>In this section, we will explore three behavioral design patterns for AWS Fargate viz., the <em><strong>Container-on-Demand</strong></em>, <em><strong>Scaling-Container</strong></em> and <em><strong>Sidecar-Assembly</strong></em> patterns that allows Fargate to be used just like Lambdas for heavy on-demand tasks where Lambda is not suitable, or allow you to run containers traditionally but without having to manage infrastructure. Additionally, we will explore how to attach sidecar containers to a parent container to provide supporting features for the application.</p>
<p>We will use the <em><strong>Container-on-Demand</strong></em> pattern to build an on-demand video thumbnail service to generate thumbnail images from video files. With this pattern, you can spin the containers on demand and immediately decommission after the task is run.</p>
<p>We will use the <em><strong>Scaling-Container</strong></em> to build an auto-scaling service that finds the value of the coins thrown on a table from an image. With this pattern, you will have a small footprint always running and scale up or down as the processing demands.</p>
<p>Later we will explore the <em><strong>Sidecar-Assembly</strong></em> pattern to deploy components of an application into a separate container to provide isolation and encapsulation.</p>
<h2 id="container-on-demand-pattern">Container-on-Demand Pattern</h2>
<h3 id="context--problem">Context &amp; Problem</h3>
<p>AWS Lambda lets you run functions as a service. This allows you to build applications as a conglomeration of serverless microservices which react to events, eschewing development of core functionalities, easy deployment, automatic scaling and fault tolerance. But Lambda has many <a href="https://docs.aws.amazon.com/lambda/latest/dg/limits.html">resource limitations</a> and in general, it is not efficient for running long-running jobs.</p>
<p>For instance, these are current limitations on Lambda (as of April 2019):</p>
<ul>
<li>The default deployment package size is 50 MB.</li>
<li>Memory range is from 128 to 3008 MB.</li>
<li>Maximum execution timeout for a function is 15 minutes.</li>
<li>Request and response (synchronous calls) body payload size can be up to to 6 MB.</li>
<li>Event request (asynchronous calls) body can be up to 128 KB.</li>
</ul>
<p>These are severe limitations for processing several types of applications including machine learning models where the size of libraries go much above the maximum deployment package size of 250MB or may take longer than 15 minutes to run a batch.</p>
<p>As a result, it is not possible to run large workloads or long running processes on Lambda. Further, the resource limitation around the size of the software package restricts the type of workloads you can run on Lambda. For instance, if you have a machine learning model that requires the usage of large libraries such as Scikit, Numpy, etc, it is impossible to fit the software package in a Lambda deployment.</p>
<h3 id="solution">Solution</h3>
<p>Deploy your software package in a container as a Fargate Task. Invoke the task using a Lambda. The Fargate Task is started from a dormant state. Once the process is complete and the output is written to the output repository, the Task is automatically stopped. As a result of this, you pay only for the time the Task is running. Additionally, you can preconfigure the size of the task (vCPU, memory, environment variables to pass parameters to the job) or override it for every invocation.</p>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/container-on-demand-pattern.png" alt="Container-on-Demand Pattern"></p>
<p>The entry point in the container can be as trivial as a shell script or could be complex as a web service. But the point to note here is the job submitted to the Fargate Task, in this case, should be asynchronous. As a result, large software packages running large workloads can be run using this pattern.</p>
<h4 id="pattern-components">Pattern Components</h4>
<ul>
<li><strong>Input Repository</strong> - The input for your <em>Processor</em> is stored here and should be reachable by the processor. This could be an S3-based object store or a database. Ideally, this repository should notify the task invoker when a new object is uploaded or updated.</li>
<li><strong>Task Invoker</strong> - A short-running function that is used to invoke your Processor. This could be a Lambda function or a synchronous service running as part of another larger process chain.</li>
<li><strong>Processor</strong> - A long-running task that is the core of the pattern. It is invoked by the Task Invoker. This could be a Fargate Task that reads its input from the Input Repository, processes it and writes back the output to the Output Repository. The Fargate task can be configured to use one or more containers (with a maximum of 10).</li>
<li><strong>Output Repository</strong> - Results of the Fargate Task are stored here. Again, this could be an S3 store or a database and could be optionally configured to emit events on inserts and updates.</li>
</ul>
<h3 id="limitations">Limitations</h3>
<p>While using this pattern Fargate puts Lambdas on steroids, Fargate has its <a href="https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_limits.html">own resource limitations</a> due to its serverless nature. For instance, the number of tasks using the Fargate launch type, per region, per account cannot be more than 50 or the maximum container storage for tasks using the Fargate launch type cannot be over 10GB.</p>
<p>If you think your workloads will breach these limitations, you should seriously consider AWS EMR or AWS Glue for your solution’s tech stack.</p>
<h2 id="scaling-container-pattern">Scaling Container Pattern</h2>
<h3 id="context--problem-1">Context &amp; Problem</h3>
<p>In the <a href="https://github.com/skarlekar/fargate-patterns#problem">problem</a> section of the <a href="https://github.com/skarlekar/fargate-patterns#container-on-demand-pattern">Container-on-Demand</a> pattern we discussed how the limitations on long-running processes rule out Lambda for asynchronous workloads. Therefore, we use the Container-on-Demand pattern to overcome the time limitation of Lambda which cannot exceed 15 minutes.</p>
<p>While the Container-on-Demand pattern solves this issue, for synchronous web services that execute within these limits, the main limitations are the <em><strong>size of the deployment package</strong></em>, networking, or the language supported in Lambda.</p>
<p>As of this writing in April 2019, AWS Lambda natively supports Java, Go, PowerShell, Node.js, C#, Python, and Ruby code. Most recently AWS Lambda provides a Runtime API which allows you to use any additional programming languages to author your functions. While the concept of allowing you to bring your own runtime is radical, it is not straight forward as can be seen from this author’s experiment <a href="https://github.com/skarlekar/lambda-custom-runtime">here</a>.</p>
<p><em><strong>How do we run synchronous services where the size of the deployment package exceeds the Lambda limits?</strong></em></p>
<p>While Lambda Layers mitigate some of this issue by allowing artifacts to be shared between Lambdas, it introduces it <a href="https://lumigo.io/blog/lambda-layers-when-to-use-it/">own set of issues</a>, especially around testing Lambdas locally and layers still count towards the 250MB hard limit on the unzipped deployment package size.</p>
<p><em><strong>What if you want to run always-on services that can scale on-demand?</strong></em></p>
<p>Note that, the Container-on-Demand pattern spins up a task to execute the job and spins it down. For asynchronous workloads, the time taken to spin-up is not an issue. But for synchronous web services, time is dear.</p>
<h3 id="solution-1">Solution</h3>
<p>Following is a possible solution to use a Fargate Service fronted by an Application Load Balancer.</p>
<ul>
<li>Deploy your service in a Fargate Task</li>
<li>Open ports for two-way communication in the Task and Container</li>
<li>Create an ECS Service to wrap around the Fargate Task.</li>
<li>Attach an Application Load Balancer in front of the Fargate Service.</li>
<li>Register an auto-scaling target with rules on when to scale out your service and when to scale it in.</li>
</ul>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/scaling-container-pattern.png" alt="enter image description here"></p>
<h4 id="pattern-components-1">Pattern Components</h4>
<ul>
<li><strong>Fargate Task</strong> - A Fargate task that has its ports open for two-way communication using one or more containers (within a maximum limit of ten containers).</li>
<li><strong>ECS Service</strong> - An ECS service that uses the Fargate Task from above identifying the desired count of tasks that must be run at any given time.</li>
<li><strong>Application Load Balancer</strong> - An Application Load Balancer with a listener to forward requests to the ECS Service.</li>
<li><strong>API Gateway</strong> - An <em>optional</em> API gateway configured to forward requests to the application load balancer.</li>
<li><strong>Web Interface</strong> - An <em>optional</em> browser-based interface for allowing users to post requests to the service. This could be a simple HTML form.</li>
</ul>
<h2 id="sidecar-assembly-pattern">Sidecar Assembly Pattern</h2>
<h3 id="problem">Problem</h3>
<p>Services require orthogonal technical capabilities, such as monitoring, logging, configuration, and networking services. While the components encapsulating these orthogonal capabilities can be integrated into the main service, it will leave the main service exposed to the vagaries of these components. For instance,  they will not be well isolated, and an outage in one of these components can affect other components or the entire service. Also, they usually need to be implemented using the same language as the parent service. As a result, the component and the main service have close interdependence on each other.</p>
<p>One option is to deploy these orthogonal components as separate services allowing each component to have its own life-cycle and be built using different languages. While this gives more flexibility, deploying these features as separate services can add latency to the application.</p>
<h3 id="solution-2">Solution</h3>
<p>Co-deploy the orthogonal components along with the main service by placing them in their own containers. Containers in a task are co-deployed together in the same host thereby not affecting the latency of the service significantly for the communication between them. As a result of this co-deployment, the sidecar and the main service can access the same resources. This allows the sidecar to monitor system resources used by both the sidecar and the primary service.</p>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/side-car-assembly.png" alt="enter image description here"></p>
<p>This pattern can also enable applications to be composed of heterogeneous components and services that have expanded capabilities beyond what is provided by these individual services. In essence, to reinforce that the whole is greater than the sum of its parts. The sidecar also shares the same lifecycle as the parent application, is created and retired alongside the parent.</p>
<hr>
<h2 id="instructions-for-running-the-examples">Instructions for Running the Examples</h2>
<h3 id="prerequisites">Prerequisites</h3>
<p>All the examples require a few prerequisites to be performed. These range from creating appropriate roles in IAM for the Lambda and Fargate to invoke AWS services. For instance, the Lambda to invoke the Fargate task, the Fargate task to read files from the S3 bucket and write back responses to it. Additionally, the S3 bucket must be prepped to notify the Lambda function.</p>
<blockquote>
<p>All these examples use AWS CLI to invoke various AWS services. To<br>
avoid the idiosyncrasies of personal development environments,  an EC2<br>
instance running Ubuntu 16.04 LTS was used to run the AWS CLI and<br>
deploy the AWS services.</p>
<p>As you run the various shell scripts indicated in the instructions,<br>
pay close attention to scripts requiring you to <em>source</em> shell<br>
scripts. This is done to carry over the environment variables<br>
generated in one script to subsequent ones.</p>
</blockquote>
<h4 id="aws-iam-setup-for-executing-the-aws-cli-commands">AWS IAM setup for executing the AWS CLI commands</h4>
<p>To be able to run the aws cli commands in the following exercises, create a group in IAM with the following permissions as shown below and assign it to the IAM user you will be using to work on this exercise.</p>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/FargateDeveloperGroup.png" alt="FargateDeveloper Group"></p>
<h4 id="development-environment-setup">Development Environment setup</h4>
<p>Start a brand new EC2 instance running Ubuntu 16.04 LTS as your development environment and in the terminal window clone the Git repository to your development environment</p>
<pre><code>$ git clone https://github.com/skarlekar/fargate-patterns.git
</code></pre>
<p>Run the <em><a href="http://prereqs-ubuntu.sh">prereqs-ubuntu.sh</a></em> script to install Docker, Python, pip, AWS CLI and other development enablers in your environment.</p>
<pre><code>$ cd fargate-patterns/prerequisities
$ prereqs-ubuntu.sh
</code></pre>
<p>Log out of your shell and log back for the newly installed programs to take effect.</p>
<p>Verify that you are able to run AWS CLI in your newly minted environment</p>
<pre><code>$ aws --version
aws-cli/1.16.144 Python/2.7.10 Darwin/18.5.0 botocore/1.12.134
</code></pre>
<h4 id="create-aws-roles-for-fargate">Create AWS roles for Fargate</h4>
<p>Create AWS roles ecsTaskExecutionRole and task roles in IAM for Fargate to access other AWS services on your behalf</p>
<pre><code>$ source ./create-roles.sh
</code></pre>
<p>Ensure the role was created by verifying the TASK_ROLE_ARN variable was set</p>
<pre><code>$ echo $TASK_ROLE_ARN
</code></pre>
<h4 id="create-vpc-subnets-and-security-group">Create VPC, Subnets and Security Group</h4>
<p>Create VPC, Subnets and Security groups for running Fargate</p>
<pre><code>$ source ./create-vpc-subnets.sh
</code></pre>
<p>Ensure the role was created by verifying the VPC, SUBNET1, SUBNET2 and SECURITYGROUP variables was set.</p>
<pre><code>$ echo echo $VPC, $SUBNET1, $SUBNET2, $SECURITYGROUP
</code></pre>
<h4 id="create-an-application-load-balancer">Create an Application Load Balancer</h4>
<p>Create an application load balancer for the Bean-Counter service we will create later</p>
<pre><code>$ source ./create-alb.sh
</code></pre>
<p>Ensure the ALB, Target Group and Listener were created successfully.</p>
<pre><code>$ echo $ALB_ARN $TG_ARN $LISTENER_ARN
</code></pre>
<p>Do not close the terminal or the shell. You will need the environment variables for running the commands below in the examples.</p>
<h2 id="examples">Examples</h2>
<p>The following code examples demonstrate these behavioral patterns.</p>
<h3 id="tom-thumb---a-video-thumbnail-generator-task">Tom Thumb - A Video Thumbnail Generator Task</h3>
<p>Tom Thumb is a video thumbnail generator task. It is implemented following the <em><strong>Container-on-Demand</strong></em> pattern.</p>
<p>In typical usage, a user uploads a video file to an S3 bucket. A trigger is set on the S3 bucket to notify a Lambda function in the event of a file upload to the <em>video</em> folder in the bucket. The Lambda is deployed with a Python code to extract the name of the video file from the Lambda notification event and <a href="https://github.com/skarlekar/tom-thumb/blob/85f5dc8527ed9c8b917119ee4f94cd61621e1b42/lambda/lambda-function.py#L29-L63">invoke a Fargate task</a>. The Fargate task consists of one container that uses FFmpeg application to decode the video and freeze an image at a given position in the video. The frozen image is written to a pre-configured folder in an S3 bucket.</p>
<h3 id="setup-instructions">Setup Instructions</h3>
<p>In the same shell that you used to run the prerequisites, run the following commands.</p>
<h4 id="create-a-repository-in-ecr">Create a repository in ECR</h4>
<p>Create a repository in ECR for storing the Tom-Thumb container image</p>
<pre><code>$ source ./create-tom-thumb-repository.sh
</code></pre>
<p>If the repository already exists, you will get an error message. This is expected. Make sure that the variable ECR_REPO_URI is set</p>
<pre><code>$ echo $ECR_REPO_URI
</code></pre>
<h4 id="build-the-docker-image">Build the Docker Image</h4>
<p>Build a Docker image and push to ECR repository</p>
<pre><code>$ ./push-to-ecr.sh
</code></pre>
<p>Ensure the latest image was pushed to the ECR Repository.</p>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/ecr-repository-tom-thumb.png" alt="ECR Repository"></p>
<h4 id="create-the-log-group">Create the Log Group</h4>
<p>Create the tom-thumb log group</p>
<pre><code>$ ./create-tom-thumb-log-group.sh
</code></pre>
<p>This will create a log group called <em>/ecs/tom-thumb-service</em></p>
<h4 id="create-the-ecs-cluster">Create the ECS Cluster</h4>
<p>Create the tom-thumb cluster in ECS</p>
<pre><code>$ ./create-tom-thumb-cluster.sh
</code></pre>
<p>This will create an ECS cluster called tom-thumb-cluster.<br>
<img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/cluster-creation-tom-thumb.png" alt="Tom-Thumb Cluster Creation"></p>
<h4 id="generate-the-task-definition">Generate the Task Definition</h4>
<p>Generate tom-thumb task definition from the template by passing an URL for a sample video and the duration in the video where you want the frame captured for the thumbnail.</p>
<pre><code>$ ./generate-tom-thumb-task-definition.sh https://s3.amazonaws.com/your-bucket-name/raw/samplevideo.mp4 10
</code></pre>
<p>This will create a temp directory and write the <em>register-tom-thumb-task-definition.json</em> file.  Inspect this file and notice that the task contains one container and it uses the my-ecs-tasks-role you created earlier to run the Fargate task.</p>
<blockquote>
<p>Referring to  <a href="https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html">the ECS<br>
documentation</a><br>
you can see that the execution role is the IAM role that executes ECS<br>
actions such as pulling the image and storing the application logs in<br>
cloudwatch. On the other hand, the TaskRole is the IAM role used by the<br>
task itself. For example, if your container wants to call other AWS<br>
services like S3, Lambda, etc,  it uses the permissions from the<br>
TaskRole to perform those actions. You need the TaskRole to avoid<br>
storing the access keys in a config file on the container instance.</p>
</blockquote>
<h4 id="register-the-task-definition">Register the Task Definition</h4>
<p>Register the tom-thumb task definition in ECS and verify it has been created in the Task Definition section of ECS.</p>
<pre><code>$ ./register-tom-thumb-task.sh
</code></pre>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/register-task-definition-tom-thumb.png" alt="Register tom-thumb task-definition"></p>
<h4 id="generate-the-parameters-for-running-the-task">Generate the parameters for running the task</h4>
<p>Generate the parameters for running the task as follows. This will generate a file run-tom-thumb-task.json in the temp directory.</p>
<pre><code>$ ./generate-run-tom-thumb-task.sh https://s3.amazonaws.com/your-bucket/raw/samplevideo.mp4 12 your-output-bucket
</code></pre>
<p>Notice that there is a section for overrides. You can make changes to this file if you want to change the parameters after the fact that the task has been registered.</p>
<h4 id="manually-run-the-task">Manually run the task</h4>
<p>Verify the task runs and generates the thumbnail as desired.<br>
$ ./run-tom-thumb-task.sh<br>
Go to the tom-thumb-cluster and verify that the task is running and the thumbnail was generated.</p>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/manually-run-task.png" alt="Manual verification of Task registration"></p>
<h4 id="create-a-lambda-trigger">Create a Lambda Trigger</h4>
<p>Create a Lambda to automatically trigger the Fargate Task when a video file lands in the desired bucket.</p>
<pre><code>$ cd lambda
</code></pre>
<h4 id="set-the-s3-bucket-arn">Set the S3 bucket ARN</h4>
<p>Identify a bucket that will notify the lambda when a video file is uploaded. Note down its ARN and set the S3_BUCKET_ARN variable.<br>
$ EXPORT S3_BUCKET_ARN=arn:aws:s3:::your-bucket-name</p>
<h4 id="create-lambda">Create Lambda</h4>
<p>Create the policies and roles required for the lambda to invoke the Fargate task.</p>
<pre><code>$ source ./create-lambda-role.sh
$ echo $LAMBDA_ROLE_ARN
</code></pre>
<p>This will create a new role called <em>my-run-task-lambda-role</em>. Verify that the role is created through the IAM section of the AWS console.</p>
<h4 id="create-a-log-group-for-lambda">Create a Log Group for Lambda</h4>
<p>Create the log group required for the lambda to post logs to CloudWatch</p>
<pre><code>$ ./create-task-runner-log-group.sh
</code></pre>
<h4 id="package-the-lambda">Package the Lambda</h4>
<p>Package the python code that has the function that will be triggered through the Lambda when a video file is uploaded. The following script will create a zip file with the Python code.</p>
<pre><code>$ ./package-lambda.sh
</code></pre>
<h4 id="deploy-the-lambda">Deploy the Lambda</h4>
<p>Deploy the zip file with the Lambda function on AWS. If the function already exists, it will be updated. This script also adds the permission for the Lambda to be invoked when a file is uploaded to the S3 bucket mentioned in the S3_BUCKET_ARN variable.</p>
<pre><code>$ ./create-lambda.sh
</code></pre>
<p>Verify the Lambda <em><strong>task-runner</strong></em> was created through the console and the following environment variables are set right for the following:</p>
<ul>
<li>SUBNET1</li>
<li>SUBNET2</li>
<li>SECURITYGROUP</li>
</ul>
<p>Additionally, verify that the Lambda permission<br>
Note: An update to the function does not update the environment variables.</p>
<h4 id="testing-tom-thumb">Testing Tom-Thumb</h4>
<ul>
<li>
<p>Create a folder called ‘video’, ‘thumbnail’ and ‘raw’ in the S3 bucket that you chose for this project. The Bucket ARN for this should match the S3_BUCKET_ARN variable you set earlier.</p>
</li>
<li>
<p>In the Console go to the Advanced Settings in the Properties tab of the S3 bucket and create a notification event to trigger the <em><strong>task-runner</strong></em> lambda that was created earlier when a file is dropped into a particular folder in your S3 bucket.</p>
</li>
</ul>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/s3-notification-setting-1.png" alt="S3 Notification Setting 1"></p>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/s3-notification-setting-2.png" alt="S3 Notification Setting 2"></p>
<ul>
<li>Upload a video file in the ‘video’ folder of the bucket and verify a thumbnail is created in the ‘thumbnail’ folder. It will take around a minute for the process to complete depending upon the size of the video file.</li>
</ul>
<hr>
<h3 id="bean-counter---a-coin-counter-service">Bean-counter - A Coin Counter Service</h3>
<p>Bean Counter is a coin counter service. It will analyze an image of coins and return the total value of the coins in the image. It works only on US Mint issued coined and does not recognize any denomination above a quarter dollar coin. It also assumes that the picture contains a quarter. The quarter is used to calibrate the size of the coins. It is implemented following the <em><strong>Scaling-Container</strong></em> pattern.</p>
<p>In typical usage, a user navigates to the URL of the ALB on the browser and enters the URL for the service along with the location of the image file containing the picture of the coins. The Bean-Counter service then invokes the Fargate Task and returns the response to the browser.</p>
<h3 id="setup-instructions-1">Setup Instructions</h3>
<p>In the same shell that you used to run the prerequisites, run the following commands.</p>
<h4 id="create-a-repository-in-ecr-1">Create a repository in ECR</h4>
<p>Create a repository in ECR for storing the Tom-Thumb container image</p>
<pre><code>$ source ./create-bean-counter-repository.sh
</code></pre>
<p>If the repository already exists, you will get an error message. This is expected. Make sure that the variable ECR_REPO_URI is set</p>
<pre><code>$ echo $ECR_REPO_URI
</code></pre>
<h4 id="build-the-docker-image-1">Build the Docker Image</h4>
<p>Build a Docker image and push to ECR repository</p>
<pre><code>$ ./push-to-ecr.sh
</code></pre>
<p>Ensure the latest image was pushed to the ECR Repository.</p>
<h4 id="create-the-log-group-1">Create the Log Group</h4>
<p>Create the bean-counter log group</p>
<pre><code>$ ./create-bean-counter-log-group.sh
</code></pre>
<p>This will create a log group called <em>/ecs/bean-counter-service</em></p>
<h4 id="create-the-ecs-cluster-1">Create the ECS Cluster</h4>
<p>Create the bean-counter cluster in ECS</p>
<pre><code>$ ./create-bean-counter-cluster.sh
</code></pre>
<p>This will create an ECS cluster called tom-thumb-cluster.</p>
<h4 id="generate-the-task-definition-1">Generate the Task Definition</h4>
<p>Generate a bean-counter task definition from the template.</p>
<pre><code>$ ./generate-bean-counter-task-definition.sh 
</code></pre>
<p>This will create a temp directory and write the <em>register-bean-counter-task-definition.json</em> file.  Inspect this file and notice that the task contains one container and it uses the my-ecs-tasks-role you created earlier to run the Fargate task.</p>
<h4 id="register-the-task-definition-1">Register the Task Definition</h4>
<p>Register the bean-counter task definition in ECS and verify it has been created in the Task Definition section of ECS.</p>
<pre><code>$ ./register-bean-counter-task.sh
</code></pre>
<h4 id="generate-the-service-definition">Generate the Service Definition</h4>
<p>Generate a bean-counter service definition from the template.</p>
<pre><code>$ ./generate-bean-counter-service-definition.sh 
</code></pre>
<p>This will create a temp directory and write the <em>create-bean-counter-service-definition.json</em> file.  Inspect this file and notice that it contains the target group for the service under the load balancers section. This ties the load balancer to the service. Also, notice the desiredCount variable set to 2.</p>
<h4 id="create-the-bean-counter-service">Create the Bean-counter Service</h4>
<p>Create the bean-counter service from the service definition file generated in the previous step.<br>
$ ./create-bean-counter-service.sh</p>
<p>Verify that the service has been created and two tasks are being provisioned for the service.</p>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/create-bean-counter-service-1.png" alt="Bean-counter Service Creation Check"></p>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/create-bean-counter-service-2.png" alt="Bean-counter Service Task Provision Check"></p>
<h4 id="testing-the-bean-counter-service">Testing the Bean-counter Service</h4>
<p>Retrieve the DNS name of the application load balancer. Cut &amp; paste the DNS in the browser.</p>
<pre><code>$ export DNS=$(aws elbv2 describe-load-balancers | jq '.LoadBalancers[] | if .LoadBalancerName == "My-Fargate-ALB" then .DNSName else null end' | grep -v null | sed "s/\"//g")
$ echo $DNS
My-Fargate-ALB-xxxxxxx.us-east-1.elb.amazonaws.com
</code></pre>
<p><img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/bean-counter-browser-1.png" alt="Bean counter landing page"><br>
<img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/bean-counter-browser-2.png" alt="Bean counter test output"></p>
<h4 id="set-the-scaling-policy-for-the-service">Set the Scaling Policy for the Service</h4>
<p>Set a target scaling policy for the service such that the desired count of the service is set to 2 and can increase to 4 on demand. The auto-scaling-policy.json specifies that when the combined load on the service breaches 75% the service should scale-out. A cool-out period of 60 seconds is also specified so that the service doesn’t thrash around.</p>
<pre><code>$ ./set-scaling-policy.sh
</code></pre>
<h4 id="test-the-scaling-policy">Test the Scaling Policy</h4>
<p>Use Apache Bench to hit the server $100,000 times with 100 concurrent threads with a timeout of 120 seconds to see the service scale out. You will have to wait for the cooling period to see the scaling out. Scaling in will take 15 minutes after scale out. Verify this on the ECS console.</p>
<pre><code>$ ./test-scaling.sh
</code></pre>
<p>Following is the output of running Apache Bench:<br>
<img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/auto-scaling-output.png" alt="Output of Apache Bench"></p>
<p>In the following picture, you can see that Fargate has scaled-out as a result of the load.<br>
<img src="https://github.com/skarlekar/fargate-patterns/blob/master/images/scaling-demo.png" alt="Fargate caught in action"></p>
<h2 id="conclusion">Conclusion</h2>
<p>Each application is unique and solving different needs based on business requirements. If the task of infrastructure management is too onerous and/or if you only want to pay for your computing time, then Fargate may be the right choice for you.</p>
<p>On the other hand, if you need greater control of the network resources or have large container workloads that warrant maintaining a cluster of servers to run ECS or EKS, then stick with the latter.</p>
<h3 id="scenarios-where-fargate-is-most-beneficial">Scenarios where Fargate is most Beneficial</h3>
<p>Fargate can be used with any type of containerized application. However, this doesn’t mean that you will get the same benefit in every scenario. Fargate would be most beneficial for projects that need to reduce the time from ideation to realization such as proofs-of-concept and well-designed, decoupled, micro service-based architectures deployed in production environments.</p>
<p><strong>Applications can consist of a mix of Fargate &amp; Lambda to exploit the Serverless model.</strong></p>
<p>Use Lambdas for small &amp; tight services with low memory (&lt;3GB) and small request-response cycles (&lt;15 mins).</p>
<p>Use containers deployed on Fargate for:</p>
<ul>
<li>Existing legacy services that cannot be trivially refactored,</li>
<li>Applications are written in languages not supported by Lambda,</li>
<li>Need to use large libraries that cannot fit into a Lambda profile (Quantlib, Scikit, etc),</li>
<li>Where you need more control over networking, compute horsepower or memory</li>
<li>Use cases that require a long in-process runtime.</li>
</ul>
<h3 id="scenarios-where-fargate-may-not-be-the-best-choice">Scenarios where Fargate may not be the Best Choice</h3>
<ul>
<li>When you require greater control of your EC2 instances to support networking, COTS applications that require broader customization options, then use ECS without Fargate.</li>
<li>When you want fast request-response cycle time then Lambda may be a good choice.  This is especially true if you are using large container images written with object-heavy languages such as Java/Scala that requires significant initiation time to start the JVM and bootstrap objects.</li>
<li>By breaking down your application into smaller modules that fit into Lambdas and using Layers and Step Functions you can reap the benefits of Serverless architectures while paying only for your compute time.</li>
</ul>

    </div>
  </div>
</body>

</html>
