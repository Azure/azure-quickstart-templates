#!/bin/bash
export SUDOUSER=$1
export OPENSHIFTUSER=$2
export OPENSHIFTPASSWORD=$3
export CLUSTERNAME=$4
export DOMAINNAME=$5
export SINGLEORMULTI=$6
export REGION=$7
export RESOURCEGROUPNAME=$8

export MULTIZONE1=1
export MULTIZONE2=2
export MULTIZONE3=3

export OCSTEMPLATES=/home/$SUDOUSER/.openshift/ocs/templates
runuser -l $SUDOUSER -c "mkdir -p $OCSTEMPLATES"

runuser -l $SUDOUSER -c "cat > $OCSTEMPLATES/toolbox.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rook-ceph-tools
  namespace: openshift-storage
  labels:
    app: rook-ceph-tools
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rook-ceph-tools
  template:
    metadata:
      labels:
        app: rook-ceph-tools
    spec:
      dnsPolicy: ClusterFirstWithHostNet
      containers:
      - name: rook-ceph-tools
        image: rook/ceph:master
        command: [\"/tini\"]
        args: [\"-g\", \"--\", \"/usr/local/bin/toolbox.sh\"]
        imagePullPolicy: IfNotPresent
        env:
          - name: ROOK_CEPH_USERNAME
            valueFrom:
              secretKeyRef:
                name: rook-ceph-mon
                key: ceph-username
          - name: ROOK_CEPH_SECRET
            valueFrom:
              secretKeyRef:
                name: rook-ceph-mon
                key: ceph-secret
        volumeMounts:
          - mountPath: /etc/ceph
            name: ceph-config
          - name: mon-endpoint-volume
            mountPath: /etc/rook
      volumes:
        - name: mon-endpoint-volume
          configMap:
            name: rook-ceph-mon-endpoints
            items:
            - key: data
              path: mon-endpoints
        - name: ceph-config
          emptyDir: {}
      tolerations:
        - key: \"node.kubernetes.io/unreachable\"
          operator: \"Exists\"
          effect: \"NoExecute\"
          tolerationSeconds: 5
EOF"

runuser -l $SUDOUSER -c "cat > $OCSTEMPLATES/ocs-olm.yaml <<EOF
---
apiVersion: v1
kind: Namespace
metadata:
  labels:
    openshift.io/cluster-monitoring: \"true\"
  name: openshift-storage
spec: {}
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-storage-operatorgroup
  namespace: openshift-storage
spec:
  targetNamespaces:
  - openshift-storage
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ocs-operator
  namespace: openshift-storage
  labels:
    operators.coreos.com/ocs-operator.openshift-storage: ''
spec:
  channel: stable-4.8
  installPlanApproval: Automatic
  name: ocs-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF"

runuser -l $SUDOUSER -c "cat > $OCSTEMPLATES/ocs-storagecluster.yaml <<EOF
apiVersion: ocs.openshift.io/v1
kind: StorageCluster
metadata:
  annotations:
    uninstall.ocs.openshift.io/cleanup-policy: delete
    uninstall.ocs.openshift.io/mode: graceful
  name: ocs-storagecluster
  namespace: openshift-storage
  finalizers:
    - storagecluster.ocs.openshift.io
spec:
  encryption:
    enable: true
  externalStorage: {}
  managedResources:
    cephBlockPools: {}
    cephFilesystems: {}
    cephObjectStoreUsers: {}
    cephObjectStores: {}
  storageDeviceSets:
    - config: {}
      count: 1
      dataPVCTemplate:
        metadata:
          creationTimestamp: null
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Ti
          storageClassName: managed-premium
          volumeMode: Block
        status: {}
      name: ocs-deviceset
      placement: {}
      portable: true
      replica: 3
      resources: {}
  version: 4.8.0
EOF"

runuser -l $SUDOUSER -c "cat > $OCSTEMPLATES/ocs-machineset-singlezone.yaml <<EOF
apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  labels:
    machine.openshift.io/cluster-api-cluster: CLUSTERID
  name: CLUSTERID-workerocs-$REGION
  namespace: openshift-machine-api
spec:
  replicas: 3
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: CLUSTERID
      machine.openshift.io/cluster-api-machineset: CLUSTERID-workerocs-$REGION
  template:
    metadata:
      labels:
        machine.openshift.io/cluster-api-cluster: CLUSTERID
        machine.openshift.io/cluster-api-machine-role: worker
        machine.openshift.io/cluster-api-machine-type: worker
        machine.openshift.io/cluster-api-machineset: CLUSTERID-workerocs-$REGION
    spec:
      taints:
      - effect: NoSchedule
        key: node.ocs.openshift.io/storage
        value: \"true\"
      metadata:
        labels:
          cluster.ocs.openshift.io/openshift-storage: \"\"
          node-role.kubernetes.io/infra: \"\"
          node-role.kubernetes.io/worker: \"\"
          role: storage-node
      providerSpec:
        value:
          apiVersion: azureproviderconfig.openshift.io/v1beta1
          credentialsSecret:
            name: azure-cloud-credentials
            namespace: openshift-machine-api
          image:
            offer: \"\"
            publisher: \"\"
            resourceID: /resourceGroups/CLUSTERID-rg/providers/Microsoft.Compute/images/CLUSTERID
            sku: \"\"
            version: \"\"
          kind: AzureMachineProviderSpec
          location: $REGION
          managedIdentity: CLUSTERID-identity
          metadata:
            creationTimestamp: null
          networkResourceGroup: $RESOURCEGROUPNAME
          osDisk:
            diskSizeGB: 512
            managedDisk:
              storageAccountType: Premium_LRS
            osType: Linux
          publicIP: false
          publicLoadBalancer: CLUSTERID
          resourceGroup: CLUSTERID-rg
          subnet: workerSubnet
          userDataSecret:
            name: worker-user-data
          vmSize: Standard_D16s_v3
          vnet: myVNet
          zone: \"\"
EOF"

runuser -l $SUDOUSER -c "cat > $OCSTEMPLATES/ocs-machineset-multizone.yaml <<EOF
---
apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  labels:
    machine.openshift.io/cluster-api-cluster: CLUSTERID
  name: CLUSTERID-workerocs-$REGION$MULTIZONE1
  namespace: openshift-machine-api
spec:
  replicas: 1
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: CLUSTERID
      machine.openshift.io/cluster-api-machineset: CLUSTERID-workerocs-$REGION$MULTIZONE1
  template:
    metadata:
      labels:
        machine.openshift.io/cluster-api-cluster: CLUSTERID
        machine.openshift.io/cluster-api-machine-role: worker
        machine.openshift.io/cluster-api-machine-type: worker
        machine.openshift.io/cluster-api-machineset: CLUSTERID-workerocs-$REGION$MULTIZONE1
    spec:
      taints:
      - effect: NoSchedule
        key: node.ocs.openshift.io/storage
        value: \"true\"
      metadata:
        labels:
          cluster.ocs.openshift.io/openshift-storage: \"\"
          node-role.kubernetes.io/infra: \"\"
          node-role.kubernetes.io/worker: \"\"
          role: storage-node
      providerSpec:
        value:
          apiVersion: azureproviderconfig.openshift.io/v1beta1
          credentialsSecret:
            name: azure-cloud-credentials
            namespace: openshift-machine-api
          image:
            offer: \"\"
            publisher: \"\"
            resourceID: /resourceGroups/CLUSTERID-rg/providers/Microsoft.Compute/images/CLUSTERID
            sku: \"\"
            version: \"\"
          kind: AzureMachineProviderSpec
          location: $REGION
          managedIdentity: CLUSTERID-identity
          metadata:
            creationTimestamp: null
          networkResourceGroup: $RESOURCEGROUPNAME
          osDisk:
            diskSizeGB: 512
            managedDisk:
              storageAccountType: Premium_LRS
            osType: Linux
          publicIP: false
          publicLoadBalancer: CLUSTERID
          resourceGroup: CLUSTERID-rg
          subnet: workerSubnet
          userDataSecret:
            name: worker-user-data
          vmSize: Standard_D16s_v3
          vnet: myVNet
          zone: \"1\"
---
apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  labels:
    machine.openshift.io/cluster-api-cluster: CLUSTERID
  name: CLUSTERID-workerocs-$REGION$MULTIZONE2
  namespace: openshift-machine-api
spec:
  replicas: 1
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: CLUSTERID
      machine.openshift.io/cluster-api-machineset: CLUSTERID-workerocs-$REGION$MULTIZONE2
  template:
    metadata:
      labels:
        machine.openshift.io/cluster-api-cluster: CLUSTERID
        machine.openshift.io/cluster-api-machine-role: worker
        machine.openshift.io/cluster-api-machine-type: worker
        machine.openshift.io/cluster-api-machineset: CLUSTERID-workerocs-$REGION$MULTIZONE2
    spec:
      taints:
      - effect: NoSchedule
        key: node.ocs.openshift.io/storage
        value: \"true\"
      metadata:
        labels:
          cluster.ocs.openshift.io/openshift-storage: \"\"
          node-role.kubernetes.io/infra: \"\"
          node-role.kubernetes.io/worker: \"\"
          role: storage-node
      providerSpec:
        value:
          apiVersion: azureproviderconfig.openshift.io/v1beta1
          credentialsSecret:
            name: azure-cloud-credentials
            namespace: openshift-machine-api
          image:
            offer: \"\"
            publisher: \"\"
            resourceID: /resourceGroups/CLUSTERID-rg/providers/Microsoft.Compute/images/CLUSTERID
            sku: \"\"
            version: \"\"
          kind: AzureMachineProviderSpec
          location: $REGION
          managedIdentity: CLUSTERID-identity
          metadata:
            creationTimestamp: null
          networkResourceGroup: $RESOURCEGROUPNAME
          osDisk:
            diskSizeGB: 512
            managedDisk:
              storageAccountType: Premium_LRS
            osType: Linux
          publicIP: false
          publicLoadBalancer: CLUSTERID
          resourceGroup: CLUSTERID-rg
          subnet: workerSubnet
          userDataSecret:
            name: worker-user-data
          vmSize: Standard_D16s_v3
          vnet: myVNet
          zone: \"2\"
---
apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  labels:
    machine.openshift.io/cluster-api-cluster: CLUSTERID
  name: CLUSTERID-workerocs-$REGION$MULTIZONE3
  namespace: openshift-machine-api
spec:
  replicas: 1
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: CLUSTERID
      machine.openshift.io/cluster-api-machineset: CLUSTERID-workerocs-$REGION$MULTIZONE3
  template:
    metadata:
      labels:
        machine.openshift.io/cluster-api-cluster: CLUSTERID
        machine.openshift.io/cluster-api-machine-role: worker
        machine.openshift.io/cluster-api-machine-type: worker
        machine.openshift.io/cluster-api-machineset: CLUSTERID-workerocs-$REGION$MULTIZONE3
    spec:
      taints:
      - effect: NoSchedule
        key: node.ocs.openshift.io/storage
        value: \"true\"
      metadata:
        labels:
          cluster.ocs.openshift.io/openshift-storage: \"\"
          node-role.kubernetes.io/infra: \"\"
          node-role.kubernetes.io/worker: \"\"
          role: storage-node
      providerSpec:
        value:
          apiVersion: azureproviderconfig.openshift.io/v1beta1
          credentialsSecret:
            name: azure-cloud-credentials
            namespace: openshift-machine-api
          image:
            offer: \"\"
            publisher: \"\"
            resourceID: /resourceGroups/CLUSTERID-rg/providers/Microsoft.Compute/images/CLUSTERID
            sku: \"\"
            version: \"\"
          kind: AzureMachineProviderSpec
          location: $REGION
          managedIdentity: CLUSTERID-identity
          metadata:
            creationTimestamp: null
          networkResourceGroup: $RESOURCEGROUPNAME
          osDisk:
            diskSizeGB: 512
            managedDisk:
              storageAccountType: Premium_LRS
            osType: Linux
          publicIP: false
          publicLoadBalancer: CLUSTERID
          resourceGroup: CLUSTERID-rg
          subnet: workerSubnet
          userDataSecret:
            name: worker-user-data
          vmSize: Standard_D16s_v3
          vnet: myVNet
          zone: \"3\"
EOF"

#Login
var=1
while [ $var -ne 0 ]; do
echo "Attempting to login $OPENSHIFTUSER to https://api.${CLUSTERNAME}.${DOMAINNAME}:6443 "
oc login "https://api.${CLUSTERNAME}.${DOMAINNAME}:6443" -u $OPENSHIFTUSER -p $OPENSHIFTPASSWORD --insecure-skip-tls-verify=true
var=$?
echo "exit code: $var"
done

# #OCS Operator will install its components only on nodes labelled for OCS with the key
# OCS_NODES=$(oc get nodes --show-labels | grep node-role.kubernetes.io/worker= |cut -d' ' -f1)
# for ocsnode in ${OCS_NODES[@]}; do
# oc label nodes $ocsnode cluster.ocs.openshift.io/openshift-storage=''
# done
## Creating ibm-ccs cr
if [[ $SINGLEORMULTI == "noha" ]];then 

CLUSTERID=$(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].metadata.labels.machine\.openshift\.io/cluster-api-cluster}')
runuser -l $SUDOUSER -c "sed -i -e s/CLUSTERID/$CLUSTERID/g $OCSTEMPLATES/ocs-machineset-singlezone.yaml"
runuser -l $SUDOUSER -c "oc create -f $OCSTEMPLATES/ocs-machineset-singlezone.yaml"
runuser -l $SUDOUSER -c "echo sleeping for 10mins untill the node comes up"
runuser -l $SUDOUSER -c "sleep 600"

elif [[ $SINGLEORMULTI == "az" ]];then 

CLUSTERID=$(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].metadata.labels.machine\.openshift\.io/cluster-api-cluster}')
runuser -l $SUDOUSER -c "sed -i -e s/CLUSTERID/$CLUSTERID/g $OCSTEMPLATES/ocs-machineset-multizone.yaml"
runuser -l $SUDOUSER -c "oc create -f $OCSTEMPLATES/ocs-machineset-multizone.yaml"
runuser -l $SUDOUSER -c "echo sleeping for 10mins untill the node comes up"
runuser -l $SUDOUSER -c "sleep 600"

fi

runuser -l $SUDOUSER -c "oc create -f $OCSTEMPLATES/ocs-olm.yaml"
runuser -l $SUDOUSER -c "echo sleeping for 5mins"
runuser -l $SUDOUSER -c "sleep 300"
runuser -l $SUDOUSER -c "oc apply -f $OCSTEMPLATES/ocs-storagecluster.yaml"
runuser -l $SUDOUSER -c "echo sleeping for 10mins"
runuser -l $SUDOUSER -c "sleep 600"
runuser -l $SUDOUSER -c "oc apply -f $OCSTEMPLATES/toolbox.yaml"
runuser -l $SUDOUSER -c "echo sleeping for 1min"
runuser -l $SUDOUSER -c "sleep 60"

echo $(date) " - ############## Script Complete ####################"