pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
        AWS_ACCOUNT_ID = '571973773340'

        ECR_REPO = 'ivolve-app'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        EKS_CLUSTER = 'ivolve-eks'
        K8S_NAMESPACE = 'ivolve'
        KUBECONFIG = '/var/lib/jenkins/.kube/config'

        AUTH_IMAGE = "${ECR_REGISTRY}/${ECR_REPO}:auth-${BUILD_NUMBER}"
        ROADMAP_IMAGE = "${ECR_REGISTRY}/${ECR_REPO}:roadmap-${BUILD_NUMBER}"
        FRONTEND_IMAGE = "${ECR_REGISTRY}/${ECR_REPO}:frontend-${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Images') {
            steps {
                sh '''
                    set -e

                    echo "Building Auth Service..."
                    docker build \
                      -t ${AUTH_IMAGE} \
                      iVolveFinalProject/auth-service

                    echo "Building Roadmap Service..."
                    docker build \
                      -t ${ROADMAP_IMAGE} \
                      iVolveFinalProject/roadmap-service

                    echo "Building Frontend..."
                    docker build \
                      -t ${FRONTEND_IMAGE} \
                      iVolveFinalProject/frontend

                    echo "Docker images built successfully."
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    set -e

                    aws ecr get-login-password \
                      --region ${AWS_REGION} \
                    | docker login \
                      --username AWS \
                      --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Push Images to ECR') {
            steps {
                sh '''
                    set -e

                    docker push ${AUTH_IMAGE}
                    docker push ${ROADMAP_IMAGE}
                    docker push ${FRONTEND_IMAGE}
                '''
            }
        }

        stage('Configure EKS') {
            steps {
                sh '''
                    set -e

                    mkdir -p "$(dirname ${KUBECONFIG})"

                    aws eks update-kubeconfig \
                      --region ${AWS_REGION} \
                      --name ${EKS_CLUSTER} \
                      --kubeconfig ${KUBECONFIG}

                    kubectl get nodes
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    set -e

                    echo "Creating namespace..."
                    kubectl apply -f kubernetes/namespace.yaml

                    echo "Applying ConfigMap..."
                    kubectl apply -f kubernetes/configmap.yaml

                    echo "Applying Secret..."
                    kubectl apply -f kubernetes/secret.yaml

                    echo "Applying StorageClass..."
                    kubectl apply -f kubernetes/storageclass.yaml

                    echo "Deploying MySQL..."
                    kubectl apply -f kubernetes/mysql/

                    echo "Deploying Auth Service..."
                    kubectl apply -f kubernetes/auth-service/

                    echo "Deploying Roadmap Service..."
                    kubectl apply -f kubernetes/roadmap-service/

                    echo "Deploying Frontend..."
                    kubectl apply -f kubernetes/frontend/

                    echo "Updating Auth Service image..."
                    kubectl set image deployment/auth-service \
                      auth-service=${AUTH_IMAGE} \
                      -n ${K8S_NAMESPACE}

                    echo "Updating Roadmap Service image..."
                    kubectl set image deployment/roadmap-service \
                      roadmap-service=${ROADMAP_IMAGE} \
                      -n ${K8S_NAMESPACE}

                    echo "Updating Frontend image..."
                    kubectl set image deployment/frontend \
                      frontend=${FRONTEND_IMAGE} \
                      -n ${K8S_NAMESPACE}
                '''
            }
        }

        stage('Deployment Status') {
            steps {
                sh '''
                    set -e

                    echo "Waiting for Auth Service..."
                    kubectl rollout status \
                      deployment/auth-service \
                      -n ${K8S_NAMESPACE} \
                      --timeout=5m

                    echo "Waiting for Roadmap Service..."
                    kubectl rollout status \
                      deployment/roadmap-service \
                      -n ${K8S_NAMESPACE} \
                      --timeout=5m

                    echo "Waiting for Frontend..."
                    kubectl rollout status \
                      deployment/frontend \
                      -n ${K8S_NAMESPACE} \
                      --timeout=5m

                    echo "======================================"
                    echo "Deployment completed successfully!"
                    echo "======================================"

                    kubectl get pods -n ${K8S_NAMESPACE}
                    kubectl get services -n ${K8S_NAMESPACE}
                '''
            }
        }
    }

    post {
        success {
            echo '======================================'
            echo 'iVolve CI/CD Pipeline completed!'
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo 'iVolve CI/CD Pipeline failed.'
            echo '======================================'
        }
    }
}
