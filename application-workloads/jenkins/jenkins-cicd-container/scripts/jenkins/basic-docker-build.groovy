node {
    def built_img = ''
    def taggedImageName = ''
    stage('Checkout git repo') {
      git branch: 'master', url: params.GIT_REPO
    }
    stage('Build Docker image') {
      built_img = docker.build(params.DOCKER_REPOSITORY + ":${env.BUILD_NUMBER}", './application-workloads/jenkins/jenkins-cicd-container/')
    }
    stage('Push Docker image to Azure Container Registry') {
      docker.withRegistry(params.REGISTRY_URL, params.REGISTRY_CREDENTIALS_ID ) {
        taggedImageName = built_img.tag("${env.BUILD_NUMBER}")
        built_img.push("${env.BUILD_NUMBER}");
      }
    }
    stage('Deploy configurations to Azure Container Service (AKS)') {
      withEnv(['TAGGED_IMAGE_NAME=' + taggedImageName]) {
          withCredentials([azureServicePrincipal('azure_service_principal')]) {
            sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID'
          }
        
        sh 'az aks get-credentials --resource-group $AKS_RESOURCE_GROUP_NAME --name $AKS_CLUSTER_NAME'
        sh 'envsubst &lt; ./application-workloads/jenkins/jenkins-cicd-container/kubernetes/hello-world-deployment.yaml | kubectl apply -f -'
        sh 'kubectl apply -f ./application-workloads/jenkins/jenkins-cicd-container/kubernetes/hello-world-service.yaml'
      }
    }
}