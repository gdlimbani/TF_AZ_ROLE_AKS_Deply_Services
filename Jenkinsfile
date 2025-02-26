pipeline {
    agent any

    environment {
        AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        AZURE_CLIENT_ID       = credentials('azure-client-id')
        AZURE_CLIENT_SECRET   = credentials('azure-client-secret')
        AZURE_TENANT_ID       = credentials('azure-tenant-id')
        TF_VAR_subscription_id = "${AZURE_SUBSCRIPTION_ID}"
        TF_VAR_client_id       = "${AZURE_CLIENT_ID}"
        TF_VAR_client_secret   = "${AZURE_CLIENT_SECRET}"
        TF_VAR_tenant_id       = "${AZURE_TENANT_ID}"
    }

    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/gdlimbani/TF_AZ_ROLE_AKS.git'
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    bat '''
                    terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    bat '''
                    terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    bat '''
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    bat '''
                    terraform output kube_config > kubeconfig.yaml
                    kubectl --kubeconfig=kubeconfig.yaml get nodes
                    '''
                }
            }
        }
    }

    post {
        always {
            node {
                cleanWs()  // Clean the workspace no matter what
            }
        }

        success {
            echo 'Deployment Successful!'
        }

        failure {
            echo 'Deployment Failed!'
        }
    }
}
