# Fargate Patterns
## Compendium and examples of a few AWS Fargate Patterns.

AWS Fargate is the Uber of container service allowing engineers to hail a container by specifying their compute and
memory needs. By providing an incredible on-demand flexibility and removing the burden of resource provisioning
just as Lambda did years ago to servers, Fargate is disrupting the container management technology.

In this workshop, we will explore three patterns viz., the Container-on-Demand, Scaling-Container and Sidecar-Assembly patterns that allows Fargate to be used just like Lambdas for heavy on-demand tasks where Lambda is not suitable.

We will use the Container-on-Demand pattern to build the Tom-Thumb on-demand task to generate thumbnail images from video files and use the Scaling-Container to build the Bean-Counter auto-scaling service that counts the coins thrown on a table.

Later we will explore the Sidecar-Assembly pattern to assemble otherwise fully functional services running in containers to build an application that has expanded capabilities beyond what is provided by these services. In essence, to reinforce that the whole is greater than sum of its parts.


