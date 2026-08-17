pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
        AWS_ACCOUNT_ID = '571973773340'
        ECR_REPO = 'ivolve-app'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        EKS_CLUSTER = 'ivolve-eks'
        K8S_NAMESPACE = 'ivolve'

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
                    docker build \
                      -t ${AUTH_IMAGE} \
                      iVolveFinalProject/auth-service

                    docker build \
                      -t ${ROADMAP_IMAGE} \
                      iVolveFinalProject/roadmap-service

                    docker build \
                      -t ${FRONTEND_IMAGE} \
                      iVolveFinalProject/frontend
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region ${AWS_REGION} \
                    | docker login \
                    --username AWS \
                    --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Push Images to ECR') {
            steps {
                sh '''
                    docker push ${AUTH_IMAGE}
                    docker push ${ROADMAP_IMAGE}
                    docker push ${FRONTEND_IMAGE}
                '''
            }
        }

        stage('Configure EKS') {
            steps {
                sh '''
                    aws eks update-kubeconfig \
                      --region ${AWS_REGION} \
                      --name ${EKS_CLUSTER}

                    kubectl get nodes
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    kubectl apply -f kubernetes/namespace.yaml
                    kubectl apply -f kubernetes/configmap.yaml
                    kubectl apply -f kubernetes/secret.yaml
                    kubectl apply -f kubernetes/storageclass.yaml

                    kubectl apply -f kubernetes/mysql/
                    kubectl apply -f kubernetes/auth-service/
                    kubectl apply -f kubernetes/roadmap-service/
                    kubectl apply -f kubernetes/frontend/

                    kubectl set image deployment/auth-service \
                      auth-service=${AUTH_IMAGE} \
                      -n ${K8S_NAMESPACE}

                    kubectl set image deployment/roadmap-service \
                      roadmap-service=${ROADMAP_IMAGE} \
                      -n ${K8S_NAMESPACE}

                    kubectl set image deployment/frontend \
                      frontend=${FRONTEND_IMAGE} \
                      -n ${K8S_NAMESPACE}
                '''
            }
        }

        stage('Deployment Status') {
            steps {
                sh '''
                    kubectl rollout status deployment/auth-service \
                      -n ${K8S_NAMESPACE}

                    kubectl rollout status deployment/roadmap-service \
                      -n ${K8S_NAMESPACE}

                    kubectl rollout status deployment/frontend \
                      -n ${K8S_NAMESPACE}
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
            echo 'iVolve CI/CD Pipeline failed.'
        }
    }
}
