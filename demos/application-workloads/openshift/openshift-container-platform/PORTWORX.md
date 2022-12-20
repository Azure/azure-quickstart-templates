### Generating the Portworx Spec URL
* Launch the [spec generator](https://central.portworx.com/specGen/wizard)
* Select Enterprise Trial or Essentials:
![Alt text](images/trial-or-essentials.png)
* Enter the Kubernetes Version and the Portworx version to 1.16.2 and 2.5 respectively, select Built-in and press Next:
![Alt text](images/kube-version-etcd.png)
* Select Azure Cloud and enter disk size to be 500 GB and press Next:
![Alt text](images/azure-disk-size.png)
* Enter eth0 for the network interfaces and press Next:
![Alt text](images/network.png)
* Select Openshift 4+ as Openshift version, go to Advanced Settings:
![Alt text](images/ocp-version.png)
* In the Advanced Settings tab select CSI and Monitoring and press Finish
![Alt text](images/enable-csi-monitoring.png)
* Copy Spec URL:
![Alt text](images/copy-spec-url.png)

