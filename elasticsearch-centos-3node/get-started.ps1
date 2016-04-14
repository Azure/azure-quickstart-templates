#get started with elastic

#This call will create a new backup repo - "mybackup1" - that will 
#	store its snapshots in Azure blob. It will create a container called 
#	'elasticsearch-snapshots' in the storage account in this resource group 
Invoke-WebRequest -Method PUT -Uri 'http://10.0.2.10:9200/_snapshot/mybackup1' -Body '{ "type": "azure" }'
	
	
#This call will create a demo index with mappings called 'shakespeare' 
Invoke-WebRequest -Method PUT -Uri 'http://10.0.2.10:9200/shakespeare' -Body '{"mappings" : {
  "_default_" : {
   "properties" : {
    "speaker" : {"type": "string", "index" : "not_analyzed" },
    "play_name" : {"type": "string", "index" : "not_analyzed" },
    "line_id" : { "type" : "integer" },
    "speech_number" : { "type" : "integer" }
   }
  }
 }}'
	 

#This call will populate the shakespeare index with data from his plays.
#	This file was downloaded by the script run by the custom script extension.
Invoke-WebRequest -Method Post -Uri 'http://10.0.2.10:9200/shakespeare/_bulk?pretty' -ContentType "application/json" -InFile "$env:Public\Desktop\shakespeare.json" 


#This call will show you stats about all the indices. 
# You should see an entry for shakespeare with data. 
Invoke-WebRequest -Method Get -Uri 'http://10.0.2.10:9200/_cat/indices?v'
  
# Or you can run this very basic search
Invoke-WebRequest -Method Get -Uri 'http://10.0.2.10:9200/shakespeare/_search?q=peace'

#It is easier to run queries and see information on the index in HQ via the shortcut on the desktop.
 
#This call will take a snapshot. You can go to the container in blob storage to verify that it was created. 
Invoke-WebRequest -Method Put -Uri 'http://10.0.2.10:9200/_snapshot/mybackup1/snapshot1?wait_for_completion=true' 

#Enjoy
 