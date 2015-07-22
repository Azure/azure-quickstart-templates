This template can be used to create a swarm cluster on azure using docker extension. It uses docker hub as a discovery service and requires token(cluster id) as a parameter. Therefore, user needs to create a token using 'docker run swarm create' command before deployment and provides it to the template.

The below token(cluster id) created using following command

test-user@swarmVMmaster:~$ docker run swarm create
65b84580f31b4d513a7d52b9c082196a

will be used in template parameter

"swarmClusterId": {
			"type": "string",
			"metadata": {
				"description": "Swarm cluster id"
			}
		}
		
