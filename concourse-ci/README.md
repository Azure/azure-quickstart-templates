# Setup Concourse CI

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fconcourse-ci%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fconcourse-ci%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

[Concourse](http://concourse.ci/) is a CI system composed of simple tools and ideas. It can express entire pipelines, integrating with arbitrary resources, or it can be used to execute one-off tasks, either locally or in another CI system.

>**NOTE:** When you deploy this template, you should choose the right location which supports DS series VMs for better performance. If you don't want to use DS series VMs, you need to update `Standard_DS` to `Standard_D` in `concourse.yml` before deploying Concourse.

## Steps

### Deploy BOSH

1. Configure `bosh.yml`

  Update your service principal (`tenant_id`, `client_id` and `client_secret`) if you don't set them in the parameters of this template.

2. Deploy

  ```
  ./deploy_bosh.sh
  ```

3. Get `director_uuid`

  ```
  bosh target 10.0.0.4 # username: admin, password: admin
  bosh status --uuid
  ```

### Deploy Concourse CI

You can click [**HERE**](http://concourse.ci/deploying-with-bosh.html) to learn more about how to deploy Concourse CI with BOSH.

The following steps are just for your information:

1. Upload the stemcell

  Get the value of **resource_pools.name[vms].stemcell.url** in **bosh.yml**, then use it to replace **STEMCELL-FOR-AZURE-URL** in below command:

  ```
  bosh upload stemcell STEMCELL-FOR-AZURE-URL
  ```

2. Upload the releases

  ```
  bosh upload release https://github.com/concourse/concourse/releases/download/v0.68.0/concourse-0.68.0.tgz
  bosh upload release https://github.com/concourse/concourse/releases/download/v0.68.0/garden-linux-0.328.0.tgz
  ```
 
3. Configure

  Update `concourse.yml` where the value is `REPLACE_WITH_*`.

4. Deploy

  ```
  bosh deployment concourse.yml
  bosh deploy
  ```

  You can use the following command to check the deployment:

  ```
  bosh vms
  ```
