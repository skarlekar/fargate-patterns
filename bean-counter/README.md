#  Bean Counter - A coin counter service

## To demonstrate building a Fargate service that auto-scales on demand

Bean Counter is a coin counter service. It will analyze an image of coins and return the total value of the coins in the image. It works only on US Mint issued coined and does not recognize any denomination above a quarter dollar coin. It also assumes that the picture contains a quarter. The quarter is used to calibrate the size of the coins. It is implemented following the ***Scaling-Container*** pattern.

In a typical usage, an user navigates to the URL of the ALB on the browser and enters the URL for the service along with the location of the image file containing the picture of the coins. The Bean-Counter service then invokes the Fargate Task and returns the response to the browser.

### Setup Instructions
- Install the prerequisites as specified here: https://github.com/skarlekar/fargate-patterns#instructions-for-running-the-examples
- Follow the instructions here to install the Bean Counter service: https://github.com/skarlekar/fargate-patterns#bean-counter---a-coin-counter-service
