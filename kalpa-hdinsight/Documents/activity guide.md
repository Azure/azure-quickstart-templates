## Activity 1: Understand & Process Real-time data.
In this activity, we will understand and Process Real-time Data and visualize it on PowerBI. Follow Following Steps to do this Activity.

 1. Login to Power BI

Open  https://app.powerbi.com/ for Login to Power BI with the provided username and password.
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea1"/>

 2. Locate Real-time Dataset

Your PowerBI username and password is already configured with the real-time dataset which have real-time social Sentiment Analysis data for some fashion brands. You can locate real-time dataset named 'salesdataset'  in the streaming dataset in left panel on the PowerBI app. Once you click on the dataset you will see a new blank report page where you can create reports on dataset.
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea2"/>

**Report Creation**

Now we will create a report on real-time data. On above screen you can see a blank report on screen. On the right side, we can see Visualizations and Fields panel.

On Visualizations panel, we can select the type of visualization we can use to visualize our data as well as the change the properties of the selected visualization.

On Fields panel, we see all the tables available in the dataset. You can drag and Drop any fields from the tables displaying on Fields Panel to the Visualization Panel's Properties.


**Follow following Steps to Create a Bar Chart.**

a. Select Table Icon on the Visualizations Panel 

b. Drag and Drop Time on the Values property  

3.	Drag and Drop Sales on Values property  

4.	Drag and Drop count on mname values property  

5.	Now you can see the Graph Plotted for the Value on the report workspace. 
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea3"/>

6.	You can try different type of visualizations for this report. Try selecting different visualizations in the Visualizations panel. 

Open the Report by clicking on it. You can Pin this Report on a live page by clicking on Pin Live Page Button on top. Once this report is pinned we can as Questions about data.

Once you click on Pin Live Page a dialog opens. Select new dashboard and name it “Realtime Data”. You can suffix your userid with the name to distingue it from others.
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea4"/>

Now you can see “Real-time Data” in Dashboard Section in left side panel. Open this dashboard to ask question about the data.

Power BI allows users to Ask questions of your data using natural language. The Q&A question box is where you type your question using natural language. Q&A recognizes the words you type and figures out where (which dataset) to find the answer. Q&A also helps you form your question with auto-completion, restatement, and other textual and visual aids.
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea5"/>

where you can ask questions like “show total sales in last two minutes” and Power bi will visualize the data for the query.

We can now filter the time window for the earlier view by adding “for last 1 minute” 
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea6"/>

You can also ask like “show  sale mname in last two minutes” and it will display maximum count of sentiment by each brand for last 5 minutes’ window.
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea7"/>

You can click on Pin Visual to save this visual on the Dashboard

You will see graph will update in real-time as the value changes.

**So far in this activity you have learned.**

1.	How to create a report from a data set. 

2.	How to pin a report to dashboard 

3.	How ask questions for data in natural language and pin visual to dashboard for live view. 

## Activity 2: Hands on with Large Data Volumes

In this activity, we will do hands on querying and reporting on Large Data Volumes on PowerBI. We will do ad hoc query on historical data and will do some slicing and dicing on large data volumes. Follow Following Steps to do this Activity.

This activity is assuming that you have completed Activity 1 and you are already logged in to the PowerBI using given Username and Password.

**Locate and Understand Dataset**

Provided Power BI account has a Dataset named “dadwdb”. This dataset contains the sales and Product data. Click on this Dataset to create a new blank report.
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea8"/>

This dataset has following tables
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea9"/>

**Report Creation**

Now we will create a report on Sales data as we did on Real-time Social Data. In this example we will be creating a line chart for daily sales for each brand and will slice that data for Country, Market and Product.

**Follow following steps to create a Line Graph.**

1.	Select Map  on the Visualizations Panel 

2.	Drag and Drop ctry_cd from Country table

3.	Drag and Drop aggr_in_tot_rtl_sls_amt in the size property 

4.  Now you can see the Graph Plotted for the Value on the report workspace:
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea10"/>

5.	You can try different type of visualizations for this report. Try selecting different visualizations in the Visualizations panel. 

**Following Steps will create a filter to for Brand.**

1.	Select Slicer Icon on the Visualizations Panel. 

2.	Drag and Drop brd_nm (Brand Name) from Brand Table to Field property 

3.	Now you can select different brand to filter sales data. 

Now save the report with the Name of your choice. For this example, we are saving this report as “Sales Quantity & Amount Report”. You can suffix Report Name with your userid to distingue from other’s reports. Once report is saved you can view this report anytime on Reports Section on left panel. You can also pin this report on the live page.
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea11"/>

**In this Activity, you have learned.**

1.	Create Report from a dataset with related tables 

2.	Create filters for slicing and dicing data. 

3.	Created summary for the data. 

**Appendix: Power Bi Users**
Following are the users that can be used for doing this activity.
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Imagea12"/>