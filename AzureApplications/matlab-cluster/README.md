# Provision a MATLAB Distributed Computing Server using Azure VMs

Run your MATLAB compute-intensive parallel workloads by creating one or more MATLAB Distributed Computing Server clusters using Azure Virtual Machines.

# Pre-Requisites

Before starting you will need the following:

- An Azure account and subscription are required to create cluster virtual machines
and Azure Storage accounts.

- Azure PowerShell is a set of modules that provide cmdlets to manage Azure with Windows PowerShell. The Azure PowerShell cmdlets are required to run the script used to create and manage the clusters.
See "[How to install and configure Azure PowerShell](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)" for installation instructions.

- MATLAB, Parallel Computing Toolbox, and MATLAB Distributed Computing Server hosted licenses; the cluster
configuration assumes that the MathWorks Hosted License Manager is used for
    all licenses. See http://www.mathworks.com/products/parallel-computing/mathworks-hosted-license-manager/.

- Access to the MATLAB Distributed Computing Server software that will need to be downloaded and then installed
on a virtual machine that will be used as a “base” VM image for the clusters.

- Copy the mdcs.ps1 file from the scripts folder to a folder on your local computer. If you do not have a GitHub account select the mdscs.ps1 file, then select the "Raw" button, then copy the text and paste it into a local file.


# Create a “Base” Virtual Machine Image

A VM that will be used as the basis for all cluster VMs needs
to be created with MATLAB Distributed Computing Server installed.

**This process normally only has to be done once; the only reason for it
to be repeated would be to cater for new versions of the MATLAB Distributed Computing Server
software. In the future we plan to remove or drastically reduce this
preparation work.**

-   Create a VM:

    -   Navigate to <https://portal.azure.com>

    -   On the left hand navigation bar select "New" | “Virtual
        Machines” | "Windows Server 2012 R2 Datacenter".

    -   Ensure "Resource Manager" is selected in the drop down box and
        select "Create".

    -   Configure the basic settings:

        -   Set the Name field; the recommendation is to include the
            MATLAB Distributed Computing Server version; e.g. “mdcsimage2016a”

        -   Pick and note down the user name and password; these will be
            required to connect to the VM later to install the
            MATLAB Distributed Computing Server software.

        -   If you do not have an existing resource group you’d like to
            use, then simply use the same value as the name field; e.g.
            “mdcsimage2016a”.

        -   Pick a location; this is normally the location that is closest
            to you and should be the same location where you will want
            the clusters created.
        - Select "OK".

    -   Configure VM size:

        -   As this is just the VM for the base image, VM size choice is
            not important; the recommended VM size is “DS2 Standard”.

    -   Settings:

        -   Storage:

            -   A storage account needs to be created to store both the
                base VM image as well as the images of the cluster VM’s.
                **It is strongly recommended that a Premium storage account is used
                to ensure optimal performance of the MATLAB software.**

           -   Set ‘Disk type’ to “Premium (SSD)”

           -   Select ‘Storage account’, then ‘Create new’

               -   For ‘Name’ enter a unique string; e.g. one that contains
                your organization name, such as “contosomdcs”

               -   The ‘Type’ is fixed at “Premium-LRS”.

        -   Monitoring:

            -   Set to “Disabled”

        -   Leave all other fields at default values; select “OK”.

    -   Summary:

        -   Select “OK” and wait for the VM to be created and
            become available.

-   Install MATLAB Distributed Computing Server on the VM:

    -   Login to the VM just created using Remote Desktop; the easiest
        way to do this is to use the Azure portal:

        -   Navigate to <https://portal.azure.com>

        -   On the left hand navigation bar select "Virtual machines”

        -   A list of virtual machines will be displayed; select the “.
            . .” in the last column for the VM (e.g. “mdcsimage2016a”);
            select “Connect”.

        -   Open the file and enter the username and password you chose
            when creating the VM to login to the VM.

    -   Download the MATLAB Distributed Computing Server software:

        -   The first time you connect to VM, a Server Manager window
            will show. Click “Local Server” on the left, and then "IE
            Enhanced Security Configuration" section, switch the
            configuration to "Off" for the administrators.

        -   Use Internet Explorer to navigate to the MathWorks web site;
            download the MATLAB Distributed Computing Server software and install in the default
            directory on the C drive. Windows 64-bit.

-   Prepare the VM so it can be used as a base image:

    -   On the VM, open a Windows PowerShell command line window in
        administrator mode. This can be done by open "Start Menu", type
        "PowerShell", and right click the item "Run as administrator"

    -   In the command window, type:

            & "\$Env:SystemRoot\\system32\\sysprep\\sysprep.exe"
            /generalize /oobe /shutdown

    -   When the command has finished, the VM will be shut down and the
        RDP connection will be closed automatically.

-   Save the VM image:
    -   Using your local computer, open a Windows PowerShell window in Admin mode run the following commands; the result will be a VHD file saved in the storage account created previously.

            # Login - provide your Azure account credentials when prompted  
            Login-AzureRmAccount

            # List all your subscription ids  
            Get-AzureRmSubscription | ft SubscriptionId

            # Pick the subscription you want to use  
            Set-AzureRmContext -SubscriptionId <subscription id>

            # Stop and deallocate the VM, it might take a while  
            Stop-AzureRmVM  
                -ResourceGroupName <resource group name>
                -name <vm name>

            # Set it to generalized format  
            Set-AzureRmVM
                -ResourceGroupName <resource group name>
                -name <VM name>
                -Generalized

            # Save the VM disk as the image for all VMs.
            Save-AzureRmVMImage
                -ResourceGroupName <resource group name>
                -VMName <VM name>
                -DestinationContainerName <use the VM name>
                -VHDNamePrefix <use the VM name>

# Cluster Management Scripts

Before any of the scripts are used Windows PowerShell must be invoked, you
must login, and you must set the subscription you want to use.

    # Login - provide your Azure account credentials when prompted
    Login-AzureRmAccount

    # List all your subscription ids
    Get-AzureRmSubscription | ft SubscriptionId

    # Pick the subscription you want to use
    Set-AzureRmContext -SubscriptionId <subscription id>

    # Change to the folder containing mdcs.ps1
    cd <folder>

The following PowerShell script enables the creation and
management of MATLAB Distributed Computing Server clusters:

    .\mdcs.ps1 <command> <command parameters>

The following commands and arguments are provided:

-   .\\mdcs create \[&lt;INI configuration filename&gt;\]

    -   Creates a cluster using a set of parameters to specify the
        cluster configuration.

    -   The optional INI file contains cluster configuration parameters
        to avoid typing in the configuration and to enable easy creation
        of different configurations by copying the INI file and only
        modifying what needs to be changed. See below for the format of
        the INI file.

    -   Note: it is recommended that up to 30 VMs can use one storage
        account for their disks; if more than 30 VMs are required then
        additional storage accounts should be created, the “base” VHD
        copied, and the INI file updated appropriately. It is therefore
        better to use fewer VM’s with more cores (1 worker per core)
        than more VM’s with fewer cores.

-   .\\mdcs list

    -   Lists created clusters together with information regarding how
        many VM’s are configured and whether the VMs are active
        or suspended.

-   .\\mdcs pause &lt;cluster name&gt;

    -   Pauses the cluster; this means that the VMs are shutdown and
        de-allocated so that there is no compute billing; the disks are
        still present in Azure storage and do incur a charge

-   .\\mdcs resume &lt;cluster name&gt;

    -   Resumes the cluster; this means that new VMs are allocated and
        started using the saved disks

-   .\\mdcs delete &lt;cluster name&gt;

    -   Deletes the specified cluster, shutting down the VMs and
        deleting the VM disks

    -   NOTE: This includes any data stored in the shared folder on the
        client node

## Create a Cluster

One way to create a cluster is from Azure portal. Click the following button will bring you to Azure portal UI to deploy MATLAB Distributed Computing Server cluster. Refer to the following section for parameter values.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmatlab-cluster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

The easiest way to specify the parameters for cluster creation is by
using an INI file; this way the configuration can be reused and
different cluster configurations created by simply copying the file and
changing only the necessary parameter values.

Multiple clusters can be created; the cluster name has to be different
for each one.

Example INI File:

    [config]
    BaseVmVhd=https://contosomdcs.blob.core.windows.net/system/Microsoft.Compute/Images/mdcsimage2016a/mdcsimage2016a-osDisk.1deb7b7c-8329-1111-2222-194f311354f3.vhd
    ClusterVmVhdContainer=https://contosomdcs.blob.core.windows.net/mdcs1/
    Region=eastus2
    ClusterName=mdcs1
    ClientVmSize=Standard_DS2
    MjsVmSize=Standard_DS2
    NumWorkersOnMjsVm=0
    WorkerVmSize=Standard_DS4
    NumWorkerVms=5
    NumWorkersOnWorkerVms=-1
    VmUsername=azureuser
    SubscriptionId=11111111-2222-3333-4444-555555555555

INI file parameters:  
- *BaseVmVhd*
    - URL to the base VM image VHD file in Azure Storage; this URL is returned from the Save-AzureRmVMImage command
    - This URL can also be obtained using the Azure Portal
        - Select “Storage accounts” for the left-hand menu; select the storage account you created; select the “Blobs” button; select “system”, “Microsoft.Compute”, “Images”, the base image name (e.g. “mdcsimage2016a”), the image file
        - The URL field is displayed and the value can be copied using the button to the left of the value.
- *ClusterVmVhdContainer*
    - The URL to the container in Azure Storage where the VM disk VHD files will be placed; a folder should be specified for each cluster.
    - Container names can contain lowercase letter, numbers, and hyphens only.
- *Region*
    - Regions for virtual machine sizes are listed on the following page:
        <https://azure.microsoft.com/en-us/regions/#services>
- *ClusterName*
    -   Name of the cluster; cluster names need to be unique.
- *ClientVmSize*
    - Size of the VM that will run the MATLAB client
    - The recommended size is "Standard_DS2"
    - VM Sizes are listed on the following page:
      <https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-size-specs/>
- *MJSVmSize*
    - Size of the VM that will run MATLAB job scheduler
    - The recommended size is "Standard_DS2"
- *NumWorkersOnMjsVm*
    - Number of MATLAB Distributed Computing Server workers to run on the VM running MATLAB job scheduler; zero workers are recommended
- *WorkerVmSize*
    - Size of the VM that will contain with MATLAB Distributed Computing Server worker processes
    -   There is one worker created per core on the VM
    -   Recommended sizes are "Standard_DS2" (2 core) to "Standard_DS14" (16 core)
- *NumWorkerVms*
    -   Number of VMs that will run MATLAB Distributed Computing Server workers
- *NumWorkersOnWorkerVms*
    - Number of MATLAB Distributed Computing Server workers to run on the worker VMs
    -   Using -1 creates one worker per core
- *VmUsername*
    - Username that can be used to login to any of the cluster VMs
- *SubscriptionId*
    - Subscription under which all VMs and storage accounts will be created


To create the cluster:

-   Use Azure PowerShell

        cd <folder containing the downloaded scripts>

        .\\mdcs create <INI file>
-   Confirm parameters values read from INI file
-   You will be prompted and need to enter the admin password
-   The script will block while provisioning the cluster and return when
    the cluster has been provisioned and is ready for use.


## Using a Cluster

A “client” VM that is used to run the MATLAB
client is created for each cluster .

-   Login to the “client” VM:
    -   Navigate to <https://portal.azure.com>
    -   On the left hand navigation bar select "Virtual machines”
    -   A list of virtual machines will be displayed; select the “. . .”
        in the last column for the client VM; select “Connect”.
    -   Open the file and enter the username and password you chose when
        creating the VM to login to the VM.

-   On the “Client” VM:
    -   Close down the Server Manager application
    -   There will be desktop icon for the MATLAB client

-   File share:

    -   If a file share is required, a share has been created on the
        “client” VM that is accessible from the worker VM’s; the path is \\\\client\\mdcsshare

-   Copying data to and from the cluster:
    -   Using Remote Desktop, it is possible to copy and paste files and
        folders between a local file system and the file system on the
        “client” VM.  It is also possible to mount the local drives
        so they appear in the file explorer on the VM.

A Cluster Profile needs to be created using the MATLAB client:

-   Invoke the Cluster Profile Manager

    -   On the “Home” tab, select “Parallel” and the “Manage Cluster
        Profiles” option

-   Create a Cluster Profile:

    -   Select the “Add” button, “Custom” option, then the “MATLAB Job
        Scheduler (MJS)” option

-   Select the “Edit” button to enter the required configuration:

    -   Optionally enter a description

    -   Enter the hostname; this will always be “MASTER”

    -   The name of the MATLAB job scheduler will always be “mymjs”

    -   You must enter the license number for the MATLAB Distributed Computing Server license
        (configured to use the Mathworks Hosted License Manager)

    -   Select “Done”

    -   Optionally rename the profile

-   Validate the profile:

    -   Select the “Validate” button on the toolbar and ensure all tests
        pass

    -   As part of the validation you will likely need to enter your
        Mathworks account email address and password; select the “Keep
        me logged on” checkbox.

## Listing Clusters

The script lists the cluster name, number of workers, and the state of
the VMs.  Running VMs, which are billed, can be distinguished
from suspended VMs).

## Pausing and Resuming a Cluster

Pausing a cluster stops the VM’s so they no longer incur compute
charges, but the disks are preserved so they will start up in the same
state and with their data preserved. For example, any data in the shared
folder on the “client” will be preserved. Charges will still be incurred
for Azure Storage.

Resuming a cluster starts the VM’s using their previously saved state.

## Deleting a Cluster

Deleting actually deletes the VM’s and their associated disks; this
includes the disk containing the share on the “client” VM.

## Feedback

We welcome any feedback on these scripts - bugs, feature requests, etc.
Please submit feedback using one of the following mechanisms:

-   Create an issue on this GitHub repository (you will need a
    GitHub account)

-   Create a post in the [Azure Batch MSDN forum](https://social.msdn.microsoft.com/forums/azure/en-US/home?forum=azurebatch).
