### Autoscale a VM Scale Set ###

The following template deploy a VM Scale Set integrated with Azure autoscale.

Deploy a simple Linux based scale set.

How to use:
- Deploy with an instance count of 1.
- SSH into port 50000 and max the CPU.
- After a few minutes additional VMs will be created.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmadhana%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-ubuntu-autoscale%2F201-vmss-ubuntu-autoscale.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<br/><br/>

### vmss-lap-autoscale.json ###

Simple self-contained Ubuntu/Apache/PHP autoscale & load balancing example. Scale Set scales up when avg CPU across all VMs > 60%, scales down when avg CPU < 50%.

- Deploy the scale set with an instance count of 1
- Browse to the website (port 80), which shows the current backend VM name.
- Hit the "Do work" button with an iteration count of say 600.
- After a few minutes the scale set capacity will increase, and refreshing the browser and going to the home page a few times will show additional backend VM name(s).
- You can increase the work by connecting to more backend websites, or decrease by letting the iterations time-out, in which case the scale set will scale down.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgbowerman%2Fazure-myriad%2Fmaster%2Fautoscale%2Fvmss-lap-autoscale.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

