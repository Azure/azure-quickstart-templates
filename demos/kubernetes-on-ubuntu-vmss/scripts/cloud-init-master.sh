#!/bin/bash
# -------

# install docker & kubeadm - ubuntu
# ---------------------------------

KUBEADM_TOKEN='8f07c4.2fa8f9e48b6d4036'
KUBE_VERSION='1.17.3-00' # specify version of kubeadm, kubelet and kubectl
KUBE_CA_VERSION='v1.17.1' # specify version of kubernetes cluster-autoscaler

# setup params given to sh script
CLIENT_ID=$1
CLIENT_SECRET=$2
RESOURCE_GROUP=$3
SUB=$4
TENANT=$5

export DEBIAN_FRONTEND=noninteractive

installDeps() {
    # update and upgrade packages
    apt-get update && apt-get upgrade -y

    # install docker
    apt-get install -y docker.io

    # install kubeadm
    apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

    apt-get update
    apt-get install -y kubelet=${KUBE_VERSION} kubeadm=${KUBE_VERSION} kubectl=${KUBE_VERSION}
}

setupKubeadm() {
    export HOME=/root
    # initialize master
    kubeadm init --pod-network-cidr=192.168.0.0/16  --token $KUBEADM_TOKEN

    # wait for kubeadm to be successfully configured
    sleep 15

    # copy /etc/kubernetes/admin.conf so we can use kubectl
    mkdir -p /root/.kube
    cp -i /etc/kubernetes/admin.conf /root/.kube/config
    chown $(id -u):$(id -g) /root/.kube/config
    export KUBECONFIG="/root/.kube/config"
    
    echo "export KUBECONFIG=/root/.kube/config" >> /root/.bashrc

    # install pod network
    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
}

setupClusterAutscaler() {
cat >/etc/cluster-vmss-autoscaler.yaml <<EOL
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
  name: cluster-autoscaler
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-autoscaler
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
rules:
  - apiGroups: [""]
    resources: ["events", "endpoints"]
    verbs: ["create", "patch"]
  - apiGroups: [""]
    resources: ["pods/eviction"]
    verbs: ["create"]
  - apiGroups: [""]
    resources: ["pods/status"]
    verbs: ["update"]
  - apiGroups: [""]
    resources: ["endpoints"]
    resourceNames: ["cluster-autoscaler"]
    verbs: ["get", "update"]
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["watch", "list", "get", "update"]
  - apiGroups: [""]
    resources:
      - "pods"
      - "services"
      - "replicationcontrollers"
      - "persistentvolumeclaims"
      - "persistentvolumes"
    verbs: ["watch", "list", "get"]
  - apiGroups: ["extensions"]
    resources: ["replicasets", "daemonsets"]
    verbs: ["watch", "list", "get"]
  - apiGroups: ["policy"]
    resources: ["poddisruptionbudgets"]
    verbs: ["watch", "list"]
  - apiGroups: ["apps"]
    resources: ["statefulsets", "replicasets", "daemonsets"]
    verbs: ["watch", "list", "get"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses", "csinodes"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["batch"]
    resources: ["jobs", "cronjobs"]
    verbs: ["watch", "list", "get"]
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["create"]
  - apiGroups: ["coordination.k8s.io"]
    resourceNames: ["cluster-autoscaler"]
    resources: ["leases"]
    verbs: ["get", "update"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create","list","watch"]
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames:
      - "cluster-autoscaler-status"
      - "cluster-autoscaler-priority-expander"
    verbs: ["delete", "get", "update", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-autoscaler
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-autoscaler
subjects:
  - kind: ServiceAccount
    name: cluster-autoscaler
    namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: cluster-autoscaler
subjects:
  - kind: ServiceAccount
    name: cluster-autoscaler
    namespace: kube-system

---
apiVersion: v1
data:
  ClientID: $(echo $CLIENT_ID | base64)
  ClientSecret: $(echo $CLIENT_SECRET | base64)
  ResourceGroup: $(echo $RESOURCE_GROUP | base64)
  SubscriptionID: $(echo $SUB | base64)
  TenantID: $(echo $TENANT | base64)
  VMType: dm1zcw==
kind: Secret
metadata:
  name: cluster-autoscaler-azure
  namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: cluster-autoscaler
  name: cluster-autoscaler
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      serviceAccountName: cluster-autoscaler
      tolerations:
        - effect: NoSchedule
          key: node-role.kubernetes.io/master
      nodeSelector:
        node-role.kubernetes.io/master: ""
      containers:
        - image: k8s.gcr.io/cluster-autoscaler:${KUBE_CA_VERSION}
          imagePullPolicy: Always
          name: cluster-autoscaler
          resources:
            limits:
              cpu: 100m
              memory: 300Mi
            requests:
              cpu: 100m
              memory: 300Mi
          command:
            - ./cluster-autoscaler
            - --v=3
            - --logtostderr=true
            - --cloud-provider=azure
            - --skip-nodes-with-local-storage=false
            - --node-group-auto-discovery=label:cluster-autoscaler-enabled=true,cluster-autoscaler-name=${RESOURCE_GROUP}
          env:
            - name: ARM_SUBSCRIPTION_ID
              valueFrom:
                secretKeyRef:
                  key: SubscriptionID
                  name: cluster-autoscaler-azure
            - name: ARM_RESOURCE_GROUP
              valueFrom:
                secretKeyRef:
                  key: ResourceGroup
                  name: cluster-autoscaler-azure
            - name: ARM_TENANT_ID
              valueFrom:
                secretKeyRef:
                  key: TenantID
                  name: cluster-autoscaler-azure
            - name: ARM_CLIENT_ID
              valueFrom:
                secretKeyRef:
                  key: ClientID
                  name: cluster-autoscaler-azure
            - name: ARM_CLIENT_SECRET
              valueFrom:
                secretKeyRef:
                  key: ClientSecret
                  name: cluster-autoscaler-azure
            - name: ARM_VM_TYPE
              valueFrom:
                secretKeyRef:
                  key: VMType
                  name: cluster-autoscaler-azure
          volumeMounts:
            - mountPath: /etc/ssl/certs/ca-certificates.crt
              name: ssl-certs
              readOnly: true
      restartPolicy: Always
      volumes:
        - hostPath:
            path: /etc/ssl/certs/ca-certificates.crt
            type: ""
          name: ssl-certs
EOL
}

installClusterAutoscaler() {
    # install cluster autoscaler
    kubectl apply -f /etc/cluster-vmss-autoscaler.yaml
}

#install flow
installDeps
setupKubeadm
setupClusterAutscaler
installClusterAutoscaler