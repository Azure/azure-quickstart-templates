# Adding an existing VMSS to a Load Balancer

Sometimes you need to expose the VMs in a VM Scale Set _after_ you created the scale set. 
For example, you may have created a kubernetes cluster and now you're deploying an app that's
exposed to the internet.

The CLI API to add a load balancer to an existing VMSS is a little bit cryptic to say the least, 
so maybe this helps.

## Setup
Let's say you created a VMSS called `myvmss` in a resource group `mygroup`.

Let's also say you created a load balancer called `mylb`.

## Steps to Take

The VMSS CLI interacts with scale sets by appying parameter files. 

1. You create a parameter file with `azure vmss config create`
2. You modify the created parameter file with any of the `azure vmss config` command
3. You apply the new configuration by running `azure vmss create` (yes ... create ... because there is no update)

Let's see how this works.

We can could create an empty parameter file or create the parameter file from the existing VMSS. I prefer the latter. 
It makes me feel a little bit safer that we're not accidentially changing another setting. 
That's probably unfounded, but it's what I prefer.









