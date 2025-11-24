pipeline {
    agent any 

    environment {
        GIT_REPO_NAME = "microservices-pipeline"
        GIT_EMAIL = "chamika.21@cse.mrt.ac.lk"
        GIT_USER_NAME = "Chamikajaya"
        IMAGE_NAME = "adservice"
        REPO_URL = "497237776404.dkr.ecr.ap-south-1.amazonaws.com/devops-microservices-dev-adservice"
        YAML_FILE = "adservice.yaml"
    }

    stages {
        stage("Clean Workspace") {
            steps {
                cleanWs()
            }
        }

        stage("Checkout Code") {
            steps {
                git branch: 'main', url: "https://github.com/Chamikajaya/microservices-pipeline.git"
            }
        }

        stage("Build Docker Image") {
            steps {
                script {
                    dir("src/adservice") {
                        sh 'docker system prune -f'
                        sh 'docker container prune -f'
                        sh 'docker build -t adservice .'
                    }
                }
            }
        }


stage("ECR Image Pushing") {
    steps {
        script {
            withAWS(credentials: 'aws-credentials', region: 'ap-south-1') {
                sh '''
                aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 497237776404.dkr.ecr.ap-south-1.amazonaws.com
                docker tag adservice:latest ${REPO_URL}:${BUILD_NUMBER}
                docker push ${REPO_URL}:${BUILD_NUMBER}
                '''
            }
        }
    }
}

        // implementing gitops -> updates k8s deployment manifest in Git, which triggers ArgoCD to deploy the new image automatically
        stage('Update Deployment file') {
            steps {
                dir('k8s') {
                    withCredentials([string(credentialsId: 'github-pat', variable: 'git_token')]) {
                        sh '''
                            echo "Configuring Git user..."
                            git config user.email "${GIT_EMAIL}"
                            git config user.name "${GIT_USER_NAME}"
                            
                            echo "Current build number: ${BUILD_NUMBER}"
                            echo "Updating ${YAML_FILE} with new image tag..."
                            
                            sed -i "s#image:.*#image: ${REPO_URL}:${BUILD_NUMBER}#g" ${YAML_FILE}
                            
                            echo "Verifying changes in ${YAML_FILE}:"
                            grep "image:" ${YAML_FILE}
                            
                            echo "Staging and committing changes..."
                            git add ${YAML_FILE}
                            git commit -m "Update ${IMAGE_NAME} image to version ${BUILD_NUMBER}"
                            
                            echo "Pushing changes to GitHub..."
                            git push https://${git_token}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                            
                            echo "Deployment file updated successfully!"
                        '''
                    }
                }
            }
        }

    }
}