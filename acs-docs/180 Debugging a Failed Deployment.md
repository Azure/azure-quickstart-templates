# 180: Debugging a Failed Deployment

Sometimes a deployment will fail. Here's some tips on how to debug such case.

## Check for errors in the portal

Navigate to the [container service](http://aka.ms/acsportal) browse UI in the portal. 

![FIXME: Container Service Browse UI with Failed Deployment](/images/180/browse_a_failed_deployment.png)

Select the service that suffered the failed deployment and click on the "Last Deployment":

![FIXME: Deployment details for a failed deployment](/images/180/failed_deployment_details.png)

Select the deployment that indicates it contains errors and click the "events" link:

![FIXME:Deployment with Errors](/images/180/deployment_with_errors.png)

Find errors in the log and click on them to get more details.

![FIXME: Finding Deployment Errors](/images/180/finding_deployment_errors.png)

## Raising a Support Request

If you need to raise a support request you should submit the deployment ID and correlation ID, these can be found in the deployment and events panes as shown below:

![FIXME: Finding the Deployment ID and Correlation ID](/images/180/finding_deployment_and_correlation_id.png)