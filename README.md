# CloudDevOpsProject

## 1. Project Overview

CloudDevOpsProject is an end-to-end Cloud DevOps project that demonstrates how to provision AWS infrastructure, configure a Jenkins CI/CD server, containerize an application, deploy it to Amazon EKS, and implement GitOps-based Continuous Deployment using ArgoCD.

The project integrates Infrastructure as Code, Configuration Management, Containerization, CI/CD, Kubernetes, and GitOps into a complete automated workflow.

---

## 2. Technologies Used

* AWS
* Terraform
* Ansible
* Docker
* Docker Compose
* Amazon EC2
* Amazon ECR
* Amazon EKS
* Kubernetes
* Jenkins
* ArgoCD
* GitHub
* MySQL

---

# 3. Architecture Overview

The project follows a cloud-native DevOps architecture.

```text
                              GitHub
                           /          \
                          /            \
                         v              v
                    Jenkins           ArgoCD
                       |                 |
                       |                 |
                 Docker Build        GitOps Sync
                       |                 |
                       v                 v
                      ECR              EKS Cluster
                                         |
                                  +------+------+
                                  |             |
                                  v             v
                              Worker Node   Worker Node
                                  |             |
                                  +------+------+
                                         |
                              Kubernetes Namespace
                                    "ivolve"
                                         |
                  +----------------------+----------------+
                  |                      |                |
                  v                      v                v
             Frontend              Auth Service     Roadmap Service
                                                          |
                                                          v
                                                       MySQL

              Terraform ───────> AWS Infrastructure
              Ansible ─────────> Jenkins Configuration
```

### Deployment Flow

1. Terraform provisions the AWS infrastructure.
2. Ansible configures the Jenkins EC2 instance.
3. Jenkins retrieves the application source code from GitHub.
4. Jenkins builds Docker images.
5. Jenkins pushes the images to Amazon ECR.
6. Jenkins connects to the Amazon EKS cluster.
7. Kubernetes manifests define the application resources.
8. ArgoCD monitors the GitHub repository.
9. ArgoCD synchronizes the Kubernetes manifests with EKS.
10. The application runs on the EKS worker nodes.

---

# 4. AWS Infrastructure

The infrastructure is deployed in the AWS region:

```text
eu-north-1
```

The AWS environment includes:

* VPC
* Public Subnets
* Private Subnets
* Internet Gateway
* NAT Gateway
* Network ACLs
* Jenkins EC2 Instance
* IAM Role for Jenkins
* Amazon ECR Repository
* Amazon EKS Cluster
* EKS Managed Node Group
* EKS Access Configuration

### VPC

The project uses a dedicated VPC containing public and private subnets.

![VPC](screenshots/vpc.png)

### VPC Resource Map

The AWS resource map provides an overview of the networking components and their relationships.

![VPC Resource Map](screenshots/vpc-resource-map.png)

---

# 5. Jenkins Server

Jenkins is hosted on an Amazon EC2 instance.

The Jenkins server is responsible for executing the CI/CD pipeline and communicating with:

* GitHub
* Docker
* Amazon ECR
* Amazon EKS

### EC2 Jenkins Server

![Jenkins EC2](screenshots/ec2.png)

The Jenkins EC2 instance uses an IAM role that allows it to authenticate with AWS services without storing static AWS access keys on the server.

The Jenkins role is also configured with access to the EKS cluster.

---

# 6. Infrastructure as Code - Terraform

Terraform is used to provision the AWS infrastructure.

The Terraform project is organized into reusable modules:

```text
terraform/
├── modules/
│   ├── network/
│   ├── server/
│   ├── ecr/
│   └── eks/
├── backend.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
└── terraform.tfvars
```

### Terraform Modules

#### Network Module

Responsible for:

* VPC
* Public Subnets
* Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Network ACLs

#### Server Module

Responsible for:

* Jenkins EC2 instance
* IAM Role
* Instance Profile
* Security Group
* SSH Key Pair

#### ECR Module

Creates the private Amazon ECR repository used by Jenkins.

#### EKS Module

Creates:

* EKS Cluster
* EKS IAM Roles
* Managed Node Group
* OIDC Provider
* EBS CSI Add-on
* Jenkins EKS Access Entry
* EKS Access Policy

### Terraform Outputs

After provisioning the infrastructure, Terraform outputs the important AWS resource information.

![Terraform Output](screenshots/terraform-output.png)

---

# 7. Configuration Management - Ansible

Ansible is used to automate the configuration of the Jenkins server.

The Ansible project contains:

```text
ansible/
├── ansible.cfg
├── inventory/
├── playbooks/
└── roles/
```

Ansible roles are used to install and configure required components including:

* Java
* Jenkins
* Trivy

This provides a repeatable and automated Jenkins server configuration.

---

# 8. Containerization - Docker

The application contains three main services:

* Auth Service
* Roadmap Service
* Frontend

Each service has its own Dockerfile:

```text
iVolveFinalProject/
├── auth-service/
│   └── Dockerfile
├── roadmap-service/
│   └── Dockerfile
└── frontend/
    └── Dockerfile
```

Docker Compose is also included for local application testing.

```bash
docker compose up --build
```

---

# 9. Amazon ECR

Amazon ECR is used as the private container registry.

Repository:

```text
ivolve-app
```

Region:

```text
eu-north-1
```

Jenkins authenticates to ECR using the AWS IAM role attached to the EC2 instance.

The pipeline builds and pushes three application images:

```text
auth-service
roadmap-service
frontend
```

Images are tagged using the Jenkins build number.

Example:

```text
auth-<BUILD_NUMBER>
roadmap-<BUILD_NUMBER>
frontend-<BUILD_NUMBER>
```

### ECR Repository

![Amazon ECR](screenshots/ecr.png)

---

# 10. Jenkins CI/CD Pipeline

The CI/CD pipeline is defined in:

```text
J
```

