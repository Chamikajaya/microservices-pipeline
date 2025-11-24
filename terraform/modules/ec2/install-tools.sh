#!/bin/bash

# Enable strict error handling
set -euo pipefail

# Setup logging
LOGFILE="/var/log/install-tools.log"
exec > >(tee -a ${LOGFILE}) 2>&1

echo "======================================"
echo "Installation started at: $(date)"
echo "======================================"

# Function to log success
log_success() {
    echo "[SUCCESS] $(date): $1"
}

# Function to log error
log_error() {
    echo "[ERROR] $(date): $1" >&2
}

# Function to check command success
check_status() {
    if [ $? -eq 0 ]; then
        log_success "$1"
    else
        log_error "$1 failed"
        return 1
    fi
}

# Update system packages
echo "Updating system packages..."
sudo yum update -y && check_status "System update"
git --version && check_status "Git verification"

# Install essential tools
echo "Installing essential tools..."
sudo yum install -y git wget unzip curl yum-utils && check_status "Essential tools installation"

# Install Java (required for Jenkins)
echo "Installing Java..."
sudo dnf install -y java-17-amazon-corretto && check_status "Java installation"
java -version && check_status "Java verification"

# Install npm
echo "Installing Node.js and npm..."
sudo dnf install nodejs -y && check_status "Node.js installation"
node -v && npm -v && check_status "Node.js/npm verification"

# Install Jenkins
echo "Installing Jenkins..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo && check_status "Jenkins repo download"
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key && check_status "Jenkins key import"
sudo yum install -y jenkins && check_status "Jenkins installation"
sudo systemctl enable jenkins && check_status "Jenkins enable"
sudo systemctl start jenkins && check_status "Jenkins start"

# Install Terraform
echo "Installing Terraform..."
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo && check_status "Terraform repo"
sudo yum install -y terraform && check_status "Terraform installation"
terraform -v && check_status "Terraform verification"

# Install Maven
echo "Installing Maven..."
sudo yum install -y maven && check_status "Maven installation"
mvn -v && check_status "Maven verification"


# Install kubectl
echo "Installing kubectl..."
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl && check_status "kubectl download"
chmod +x ./kubectl && check_status "kubectl chmod"
sudo mv ./kubectl /usr/local/bin/ && check_status "kubectl move"
kubectl version --client && check_status "kubectl verification"

# Install eksctl
echo "Installing eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && check_status "eksctl download"
sudo mv /tmp/eksctl /usr/local/bin/ && check_status "eksctl move"
eksctl version && check_status "eksctl verification"

# Install Helm
echo "Installing Helm..."
wget https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz && check_status "Helm download"
tar -zxvf helm-v3.6.0-linux-amd64.tar.gz && check_status "Helm extract"
sudo mv linux-amd64/helm /usr/local/bin/helm && check_status "Helm move"
chmod +x /usr/local/bin/helm && check_status "Helm chmod"
rm -rf helm-v3.6.0-linux-amd64.tar.gz linux-amd64 && check_status "Helm cleanup"
helm version && check_status "Helm verification"

# Install Docker
echo "Installing Docker..."
sudo yum install -y docker && check_status "Docker installation"
sudo usermod -aG docker ec2-user && check_status "ec2-user Docker group"
sudo usermod -aG docker jenkins && check_status "jenkins Docker group"
sudo systemctl enable docker && check_status "Docker enable"
sudo systemctl start docker && check_status "Docker start"
sudo chmod 777 /var/run/docker.sock && check_status "Docker socket permissions"
sudo docker --version && check_status "Docker verification"

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && check_status "Docker Compose download"
sudo chmod +x /usr/local/bin/docker-compose && check_status "Docker Compose chmod"
sudo docker-compose --version && check_status "Docker Compose verification"

# Run SonarQube using Docker
echo "Running SonarQube..."
sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community && check_status "SonarQube container start"
sleep 5
sudo docker ps | grep sonar && check_status "SonarQube container verification"

# Install Trivy
echo "Installing Trivy..."
sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.48.3/trivy_0.48.3_Linux-64bit.rpm && check_status "Trivy installation"
trivy --version && check_status "Trivy verification"

echo "======================================"
echo "Installation completed at: $(date)"
echo "Log file available at: ${LOGFILE}"
echo "======================================"