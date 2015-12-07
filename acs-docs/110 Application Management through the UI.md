110: Application Management through the UI

Thursday, November 19, 2015

1:38 PM

 

If you elected to configure a "jumpbox" you can create a VNC (for Linux jumpboxes) or RDP (Windows jumpboxes) connection to that machine and work with the UI from there. The first thing you need to do is configure an SSH tunnel to your cluster, see [108: Connecting to Orchestration Management Interfaces](onenote:#108%20Connecting%20to%20Orchestration%20Management%20Interfaces&section-id={CFB761B4-3A3C-488C-A3F0-A31102E5F7F5}&page-id={B28097A5-BEB4-47B7-B5F0-7680ED286660}&end&base-path=https://d.docs-df.live.net/d66b9407fb17d322/Documents/COntainer%20Service/Docs.one)

 

VNC Connections for Linux Jumpboxes

 

If you elected to use a Linux Jumpbox then you will use VNC to connect to it. You will have needed to provide a tunnel to port 5901:

 

![](images\110/media/image1.png)

 

For more information on how to open a tunnel see [108: Connecting to Orchestration Management Interfaces](onenote:#108%20Connecting%20to%20Orchestration%20Management%20Interfaces&section-id={CFB761B4-3A3C-488C-A3F0-A31102E5F7F5}&page-id={B28097A5-BEB4-47B7-B5F0-7680ED286660}&end&base-path=https://d.docs-df.live.net/d66b9407fb17d322/Documents/COntainer%20Service/Docs.one).

 

Now install a VNC Client on your client (e.g. <http://www.realvnc.com/download/viewer/>)

 

Once installed open the client and connect as follows:

 

 

 

![](images\110/media/image2.png)

 

 

 

11/20/2015 2:24 PM - Screen Clipping

 

With the password of \`password\`.

 

![](images\110/media/image3.png)

 

You can now open a browser and view:

 

Now you can open a browser and visit:

-   Mesos: <http://master0:5050>

-   Marathon: <http://master0:8080>

-   Chronos: <http://master0:4400>

 

 

![](images\110/media/image4.png)

 

 

 

11/20/2015 2:27 PM - Screen Clipping

 

 

Remote Desktop for Windows Jumpbox

 

In the Azure portal navigate to your Jumpbox within your resource group:

 

![](images\110/media/image5.png)

 

![](images\110/media/image6.png)

 

Click the Connect button:

 

![](images\110/media/image7.png)

 

Optionally Save the file for easy access later. Open it now.

 

![](images\110/media/image8.png)

 

Connect:

![](images\110/media/image9.png)

 

![](images\110/media/image10.png)

 

![](images\110/media/image11.png)

 

![](images\110/media/image12.png)

Now you can open a browser and visit:

-   Mesos: <http://master0:5050>

-   Marathon: <http://master0:8080>

-   Chronos: <http://master0:4400/>
