# Azure SLES 12 HPC ARM Template

Deploys a SLURM cluster with head node and n worker nodes.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fslurm-on-sles12-hpc%2Fazuredeploy.json" target="_blank">
   <img alt="Deploy to Azure" src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fslurm-on-sles12-hpc%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

1. Fill in the 3 mandatory parameters - public DNS name, a storage account to hold VM image, and admin user password.

2. Select an existing resource group or enter the name of a new resource group to create.

3. Select the resource group location.

4. Accept the terms and agreements.

5. Click Create.

## Accessing the cluster

Simply SSH to the master node using the DNS name _**dnsName**_._**location**_.cloudapp.azure.com, for example, slurm12-hpc.westus.cloudapp.azure.com.

```
# ssh azureuser@slurm12-hpc.westus.cloudapp.azure.com
```

You can log into the head node using the admin user and password specified.  Once on the head node you can switch to the HPC user.  For security reasons the HPC user cannot login to the head node directly.

## Running workloads

### HPC User

After SSHing to the head node you can switch to the HPC user specified on creation, the default username is 'hpc'.  

This is a special user that should be used to run work and/or SLURM jobs.  The HPC user has public key authentication configured across the cluster and can login to any node without a password.  The HPC users home directory is a NFS share on the master and shared by all nodes.

To switch to the HPC user.

```
azureuser@master:~> sudo su hpc
azureuser's password:
hpc@master:/home/azureuser>
```

### Shares

The master node doubles as a NFS server for the worker nodes and exports two shares, one for the HPC user home directory and one for a data disk.

The HPC users home directory is located in /share/home and is shared by all nodes across the cluster.

The master also exports a generic data share under /share/data.  This share is mounted under the same location on all worker nodes.  This share is backed by 16 disks configured as a RAID-0 volume.  You can expect much better IO from this share and it should be used for any shared data across the cluster.

### Running a SLURM job

To verify that SLURM is configured and running as expected you can execute the following.

```
hpc@master:~> srun -N6 hostname
worker4
worker0
worker2
worker3
worker5
worker1
hpc@master:~>
```

Replace '6' above with the number of worker nodes your cluster was configured with.  The output of the command should print out the hostname of each node.

### VM Sizes

#### Head Node

The master/head node only supports VM sizes that support up to 16 disks being attached, hence >= A4.

#### Worker Nodes

Worker nodes support any VM size.

### MPI

To run MPI applications you'll need to use the A8/A9 instances which include InfiniBand and RDMA support.  We suggest using A8 for the head node and A9 instances for worker nodes.

Currently RDMA only supports Intel MPI.  You can download the Intel pieces and get an evaluation license from https://software.intel.com/en-us/intel-mpi-library.
