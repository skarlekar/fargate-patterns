#  Tom Thumb - A Video Thumbnail Generator Task

## To demonstrate invoking a long-running Fargate task on demand using Lambda

Tom Thumb is a video thumbnail generator task. It is implemented following the ***Container-on-Demand*** pattern.

In a typical usage, an user uploads a video file to a S3 bucket. A trigger is set on the S3 bucket to notify a Lambda function in the event of a file upload to the *video* folder in the bucket. The Lambda is deployed with a Python code to extract the name of the video file from the Lambda notification event and [invoke a Fargate task](https://github.com/skarlekar/tom-thumb/blob/85f5dc8527ed9c8b917119ee4f94cd61621e1b42/lambda/lambda-function.py#L29-L63). The Fargate task consists of one container that uses ffmpeg application to decode the video and freeze an image at a given position in the video. The frozen image is written to a pre-configured folder in a S3 bucket.

### Setup Instructions
- Install the prerequisites as specified here: https://github.com/skarlekar/fargate-patterns#instructions-for-running-the-examples
- Follow the instructions here to install the Tom Thumb task: https://github.com/skarlekar/fargate-patterns#tom-thumb---a-video-thumbnail-generator-task
