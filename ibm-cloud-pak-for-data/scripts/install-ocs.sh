#!/bin/bash
export SUDOUSER=$1
export OPENSHIFTUSER=$2
export OPENSHIFTPASSWORD=$3
export CLUSTERNAME=$4
export DOMAINNAME=$5

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
        image: rook/ceph:v1.1.9
        command: [\"/tini\"]
        args: [\"-g\", \"--\", \"/usr/local/bin/toolbox.sh\"]
        imagePullPolicy: IfNotPresent
        env:
          - name: ROOK_ADMIN_SECRET
            valueFrom:
              secretKeyRef:
                name: rook-ceph-mon
                key: admin-secret
        securityContext:
          privileged: true
        volumeMounts:
          - mountPath: /dev
            name: dev
          - mountPath: /sys/bus
            name: sysbus
          - mountPath: /lib/modules
            name: libmodules
          - name: mon-endpoint-volume
            mountPath: /etc/rook
      # if hostNetwork: false, the \"rbd map\" command hangs, see https://github.com/rook/rook/issues/2021
      hostNetwork: true
      volumes:
        - name: dev
          hostPath:
            path: /dev
        - name: sysbus
          hostPath:
            path: /sys/bus
        - name: libmodules
          hostPath:
            path: /lib/modules
        - name: mon-endpoint-volume
          configMap:
            name: rook-ceph-mon-endpoints
            items:
            - key: data
              path: mon-endpoints
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
spec:
  channel: stable-4.5
  installPlanApproval: Automatic
  name: ocs-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: ocs-operator.v4.5.2
EOF"

runuser -l $SUDOUSER -c "cat > $OCSTEMPLATES/ocs-storagecluster.yaml <<EOF
apiVersion: ocs.openshift.io/v1
kind: StorageCluster
metadata:
  namespace: openshift-storage
  name: ocs-storagecluster
  finalizers:
    - storagecluster.ocs.openshift.io
spec:
  externalStorage: {}
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
              storage: 2Ti
          storageClassName: managed-premium
          volumeMode: Block
        status: {}
      name: ocs-deviceset
      placement: {}
      portable: true
      replica: 3
      resources: {}
  version: 4.5.0
EOF"

#Login
var=1
while [ $var -ne 0 ]; do
echo "Attempting to login $OPENSHIFTUSER to https://api.${CLUSTERNAME}.${DOMAINNAME}:6443 "
oc login "https://api.${CLUSTERNAME}.${DOMAINNAME}:6443" -u $OPENSHIFTUSER -p $OPENSHIFTPASSWORD --insecure-skip-tls-verify=true
var=$?
echo "exit code: $var"
done

#OCS Operator will install its components only on nodes labelled for OCS with the key
OCS_NODES=$(oc get nodes --show-labels | grep node-role.kubernetes.io/worker= |cut -d' ' -f1)
for ocsnode in ${OCS_NODES[@]}; do
oc label nodes $ocsnode cluster.ocs.openshift.io/openshift-storage=''
done
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