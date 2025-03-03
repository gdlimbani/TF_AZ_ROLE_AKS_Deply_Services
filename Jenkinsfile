pipeline {
    agent any

    environment {
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_CLIENT_ID       = credentials('azure-client-id')
        ARM_CLIENT_SECRET   = credentials('azure-client-secret')
        ARM_TENANT_ID       = credentials('azure-tenant-id')
    }

    stages {
        // stage('Clone Repo') {
        //     steps {
        //         git 'https://github.com/gdlimbani/TF_AZ_ROLE_AKS.git'
        //     }
        // }

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

        // stage('Verify Deployment') {
        //     steps {
        //         script {
        //             bat '''
        //             terraform output kube_config > kubeconfig.yaml
        //             kubectl --kubeconfig=kubeconfig.yaml get nodes
        //             '''
        //         }
        //     }
        // }
    }

    post {
        always {
            cleanWs()  // Clean the workspace no matter what
        }

        success {
            echo 'Deployment Successful!'
        }

        failure {
            echo 'Deployment Failed!'
        }
    }
}
