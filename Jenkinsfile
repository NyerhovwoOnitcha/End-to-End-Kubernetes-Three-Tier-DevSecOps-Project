properties([
    parameters([
        string(
            defaultValue: 'dev',
            name: 'Environment'
        ),
        choice(
            choices: ['plan', 'apply', 'destroy'], 
            name: 'Terraform_Action'
        )])
])
pipeline {
    agent any
    stages {
        stage('Preparing') {
            steps {
                sh 'echo Preparing'
            }
        }
        stage('Git Pulling') {
            steps {
                git branch: 'master', url: 'https://github.com/NyerhovwoOnitcha/End-to-End-Kubernetes-Three-Tier-DevSecOps-Project.git'
            }
        }
        stage('Create Backend Resources') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'eu-north-1') {
                    sh '''
                    terraform init
                    terraform apply -auto-approve -target=aws_s3_bucket.eks_s3 -target=aws_s3_bucket_versioning.eks_s3_versioning -target=aws_dynamodb_table.eks_s3_dynamodb-table
                    '''
                }
            }
        }
        stage('Init') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'eu-north-1') {
                    sh 'terraform -chdir=eks/ init -backend-config="bucket=eks-s3-terraform-bucket" -backend-config="key=eks/terraform.tfstate" -backend-config="region=eu-north-1" -backend-config="dynamodb_table=EksTable" -backend-config="encrypt=true"'
                }
            }
        }
        stage('Validate') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'eu-north-1') {
                    sh 'terraform -chdir=eks/ validate'
                }
            }
        }
        stage('Action') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'eu-north-1') {
                    script {    
                        if (params.Terraform_Action == 'plan') {
                            sh "terraform -chdir=eks/ plan -var-file=${params.Environment}.tfvars"
                        } else if (params.Terraform_Action == 'apply') {
                            sh "terraform -chdir=eks/ apply -var-file=${params.Environment}.tfvars -auto-approve"
                        } else if (params.Terraform_Action == 'destroy') {
                            sh "terraform -chdir=eks/ destroy -var-file=${params.Environment}.tfvars -auto-approve"
                        } else {
                            error "Invalid value for Terraform_Action: ${params.Terraform_Action}"
                        }
                    }
                }
            }
        }
    }
}
