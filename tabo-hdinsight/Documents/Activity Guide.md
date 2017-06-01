## Tabo Activity Guide

**Activity 1: Understand & Process Real-time data**

In this activity, we will understand and Process Real-time Data and visualize it on Power BI. Follow below Steps to do this activity. 
1. Login to Power BI
  Open https://app.powerbi.com/ and click on "Sign In" for Login to Power BI with the provided username and password.
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea1.png"/>

2. Go To Your Workspace
  To get Navigation Panel on Left Side Click on Power BI Icon at the Top.
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea2.png"/>
    
  By Default you are in **"My workspace Group"**. You need to change it to "**IOT Activities**" from the left side Navigation Panel.
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea3.png"/>
  
3. Locate Real-time Dataset
  Your Power Bi username and password is already configured with the real-time dataset which have real-time IOT data coming from SAP Database. You can locate real-time dataset named **"iotdata - Copy"** in left navigation panel on the Power Bi app under **Datasets**. Once you click on the dataset yowill see a new blank report page where you can create reports on dataset.
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea4.png"/>
  
4. Report Creation
  Now we will create a report on real-time data. On above screen you can see a blank report on screen. On the right side we can see Visualizations and Fields panel. 
  For this example we are going to create a Line Chart which displays Safety Score of Equipment's. By following below steps you can create your own Line Chart-
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea5.png"/>

  a. Select Line Chart Icon from the Visualizations Panel
  b. Drag and Drop three fields from Fields tab to Visualizations Tab like below:
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea6.png"/>
     
  c. By default it will take sum of Values Field in Visualizations Tab. To take average of this "normalizedScore" column fields, select Average 
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea7.png"/>

  d. Now you can see the Graph Plotted similar like this, we have to use some filters to make it readable.
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea8.png"/>

  e. So to filter out only latest data, we can use Filters option from Visualizations Tab
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea9.png"/>

   Click on EventEnqueuedUtcTime(All) to expand it then choose Filter Type "Advance Filtering"
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea10.png"/>

   Now select "is on or after" like below:
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea11.png"/>

   Then give your live time as an input using calendar and clock, hit "Apply filter" below
   (NOTE- Our servers are working according to GMT Time so in Atlanta time would be GMT-4)
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea12.png"/>

  f. You can also give a proper title to this visual by clicking Format in Visualizations Tab
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea13.png"/>

  g. Save this Report by clicking on File -> Save (or ctrl + s), Give it a name and hit Save
       (NOTE- Please give your report name as your username of Power Bi, so it won't conflict with other's report, you can use Report as suffix for ex. User1_Report)
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea14.png"/>
       
  h. You will see generating data live once you pin it to the Dashboard. (In next Step)

  5. Create a Dashboard
    Now we will create a Dashboard using this Report we just created.
  a. Select your saved Report from Navigation Panel under Reports 
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea15.png"/>
     
  b. Now we can pin this Visual of a Report in a new Dashboard by clicking on Pin button like below
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea16.png"/>
     
  c. Select "New Dashboard", give it a name and hit Pin


  d. (NOTE- Please give your Dashboard name as your username of Power Bi, so it won't conflict with other's Dashboard, you can use Dashboard as suffix for ex. User1_Dashboard)
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea17.png"/>
 
  e. Now you can see a new Dashboard in Navigation Panel under Dashboards  
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea18.png"/>
     
  (Now this visual will be updating in Real Time since Power Bi Dashboard supports live Streaming Data.)

  f. Now try to add more tiles by using Power BI Q&A Feature on Live Streaming Data - 
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea19.png"/>
       
  Click on this and write a query like this **"event enqueued utc time EQUIPMENT voltage in last 2 minutes"**, it will show you Voltage Status of last 2 Minutes.
  Make sure you select Average of Voltage in Values field from Visualizations Tab.  Click on 
 
  It will look something like this
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea20.png"/>

   g. You can also give a proper title to this visual too as shown above Screenshot in the right Visualizations panel.

   h. Now to add this visual in Dashboard click on Pin visual from Top Right Corner as shown in above Screenshot. It will ask you to add this visual on existing dashboards.  

   i. Now go back by clicking **"Exit Q&N"** on top. 

 Your Dashboard might be look like this-
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea21.png"/>

**Activity 2: Creating Report with SAP HISTORICAL DATA**
  
  1. Locate SAP HISTORICAL Dataset
    You can locate dataset named **"SAP_HIST_IOT_DATA - Copy"** in left navigation panel on the Power Bi app under Datasets. Once you click on the dataset you will see a new blank report page where you can create reports on dataset.
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea22.png"/>

  2. Create a Report
    Now we will create a report on this Dataset. On above screen you can see a blank report on screen. On the right side we can see Visualizations and Fields panel. 
    i.)Table-
    a.)Select a Table from Visualizations tab-
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea23.png"/>

   b.) Now drag some column from Fields tab in Visualizations tab's Values like below
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea24.png"/>
	  
   c.) Zoom in table by using Format option in Visualizations Tab
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea25.png"/>
        

   d.) The table will look like this
         (It is showing the notification details of a Maintenance Orders)
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea26.png"/>
      
   e.) To make another visual you can use page 2 by clicking button below 
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea27.png"/>

   ii.) Line Chart-
   a.) Select a Line Chart from Visualizations tab  
 <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea28.png"/>

  b.) Now drag three columns from Fields tab in Visualizations tab's
  (I) DATE ON WHICH RECORD WAS CREATED 
  (II) PLANT LOCATION
  (III) ORDER NO
    Like given below
    (Remove all the other sub columns like Month, Day, and Quarter except Year by clicking)
 	<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea29.png"/>
        
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea30.png"/>		 


   c.) Using format option we have to change X-axis type to Categorical from Continuous
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea31.png"/>

   d.) You can also set title of this visual by using title option 
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea32.png"/>

   e.) Finally the visual will look like this
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/images/Imagea33.png"/>
