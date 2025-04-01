#!/bin/bash

# Get current host IP (won't change it)
HOST_IP=$(hostname -I | awk '{print $1}')

# Step 1: Install dependencies
sudo apt update -y
sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

sudo apt-get update && sudo apt-get upgrade -y --no-install-recommends --allow-downgrades --allow-remove-essential --allow-change-held-packages --no-restart
sudo apt install python3 -y
sudo apt install python3-pip -y
sudo apt install -y git curl helm terraform

pip3 install --upgrade pip
pip install ansible-core==2.14.11
pip3 install ansible


# Update system packages
echo "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y --no-install-recommends --allow-downgrades --allow-remove-essential --allow-change-held-packages --no-restart


for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update && sudo apt-get upgrade -y --no-install-recommends --allow-downgrades --allow-remove-essential --allow-change-held-packages --no-restart
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y





# Configure Docker network
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "default-address-pools": [
    {"base": "172.80.0.0/16", "size": 24}
  ]
}

EOF

# Restart Docker
echo "Restarting Docker..."
sudo systemctl restart docker

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create GitLab docker-compose file
echo "Creating GitLab configuration..."
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  gitlab:
    image: 'gitlab/gitlab-ce:latest'
    restart: always
    hostname: 'gitlab.example.com'
    environment:
      GITLAB_ROOT_EMAIL: "admin@gmail.com"
      GITLAB_ROOT_PASSWORD: "Abcd@0123456789"
      external_url: 'http://$HOST_IP'
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - '/srv/gitlab/config:/etc/gitlab'
      - '/srv/gitlab/logs:/var/log/gitlab'
      - '/srv/gitlab/data:/var/opt/gitlab'
EOF

# Create data directories
echo "Creating data directories..."
sudo mkdir -p /srv/gitlab/{config,logs,data}

# Start GitLab
echo "Starting GitLab..."
sudo docker-compose up -d

echo "Waiting for GitLab to initialize (4 minutes)..."
sleep 240

# Display completion information
echo "Installation complete! of gitlab "


#!/bin/bash

# Step 1: Install dependencies
sudo apt update -y
sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

sudo apt update -y
sudo apt install python3 -y
sudo apt install python3-pip -y
sudo apt install -y git curl helm terraform

pip3 install --upgrade pip
pip install ansible-core==2.14.11
pip3 install ansible

touch main.tf
# Create the Terraform file
cat > main.tf<< 'EOF'
terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

resource "null_resource" "kubespray" {
  provisioner "local-exec" {
    command = <<-EOT
      git clone https://github.com/kubernetes-sigs/kubespray.git && \
      cd kubespray && \
      git checkout release-2.21 && \
      pip3 install -r requirements.txt && \
      cp -rfp inventory/sample inventory/mycluster && \
      echo "[all]" > inventory/mycluster/inventory.ini && \
      echo "localhost ansible_connection=local" >> inventory/mycluster/inventory.ini && \
      echo "[kube_control_plane]" >> inventory/mycluster/inventory.ini && \
      echo "localhost" >> inventory/mycluster/inventory.ini && \
      echo "[etcd]" >> inventory/mycluster/inventory.ini && \
      echo "localhost" >> inventory/mycluster/inventory.ini && \
      echo "[kube_node]" >> inventory/mycluster/inventory.ini && \
      echo "localhost" >> inventory/mycluster/inventory.ini && \
      echo "[k8s_cluster:children]" >> inventory/mycluster/inventory.ini && \
      echo "kube_control_plane" >> inventory/mycluster/inventory.ini && \
      echo "kube_node" >> inventory/mycluster/inventory.ini && \
      echo 'supplementary_addresses_in_ssl_keys: ["{{ ansible_default_ipv4.address }}", "kubernetes", "kubernetes.default", "kubernetes.default.svc"]
      kube_access_addresses: []
      sans_override: []' >> inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml && \
      echo "auto_renew_certificates: true" &&\
      echo "skip_fallback_ips: true" >> inventory/mycluster/group_vars/all/all.yml && \
      echo "etc_hosts_inventory_block: |" >>inventory/mycluster/group_vars/all/all.yml && \
      echo " {{ ansible_default_ipv4.address }} {{ inventory_hostname }} {{ ansible_hostname }}" >> inventory/mycluster/group_vars/all/all.yml && \
      ansible-playbook \
        -i inventory/mycluster/inventory.ini \
        cluster.yml
    EOT
  }
}
EOF


terraform init
terraform apply -auto-approve



curl -s https://fluxcd.io/install.sh | sudo bash


export GITHUB_TOKEN=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
export GITHUB_USER=mortazakiani
flux bootstrap github --owner=$GITHUB_USER --repository=fluxcd --branch=master --path=clusters/my-cluster --personal


#!/bin/bash

# Set chart name
CHART_NAME="pizza-chart"

# Remove existing chart if exists
rm -rf $CHART_NAME

# Create a new Helm chart
helm create $CHART_NAME

# Update Chart.yaml
cat <<EOF > $CHART_NAME/Chart.yaml
apiVersion: v2
name: $CHART_NAME
description: A Helm chart for deploying Pizza Frontend and Backend
version: 1.0.0
appVersion: "1.0"
EOF

# Update values.yaml
cat <<EOF > $CHART_NAME/values.yaml
replicaCount: 1

image:
  frontend: mortazakiani/pizza-frontend:v1
  backend: mortazakiani/pizza-backebnd:v1

environment: Development

service:
  frontend:
    port: 80
  backend:
    port: 8080

ingress:
  enabled: true
  host: mortezakianitadi.maxtld.dev
  path:
    frontend: /frontend
    backend: /endpoints
EOF

# Update deployment.yaml
cat <<EOF > $CHART_NAME/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pizza-frontend
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: pizza-frontend
  template:
    metadata:
      labels:
        app: pizza-frontend
    spec:
      containers:
        - name: pizza-frontend
          image: {{ .Values.image.frontend }}
          ports:
            - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pizza-backend
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: pizza-backend
  template:
    metadata:
      labels:
        app: pizza-backend
    spec:
      containers:
        - name: pizza-backend
          image: {{ .Values.image.backend }}
          env:
            - name: ASPNETCORE_ENVIRONMENT
              value: {{ .Values.environment }}
          ports:
            - containerPort: {{ .Values.service.backend.port }}
EOF

# Update service.yaml
cat <<EOF > $CHART_NAME/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: pizza-frontend-service
spec:
  selector:
    app: pizza-frontend
  ports:
    - protocol: TCP
      port: {{ .Values.service.frontend.port }}
      targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: pizza-backend-service
spec:
  selector:
    app: pizza-backend
  ports:
    - protocol: TCP
      port: {{ .Values.service.backend.port }}
      targetPort: {{ .Values.service.backend.port }}
EOF

# Update ingress.yaml
cat <<EOF > $CHART_NAME/templates/ingress.yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: pizza-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: {{ .Values.ingress.host }}
      http:
        paths:
          - path: {{ .Values.ingress.path.frontend }}
            pathType: Prefix
            backend:
              service:
                name: pizza-frontend-service
                port:
                  number: {{ .Values.service.frontend.port }}
          - path: {{ .Values.ingress.path.backend }}
            pathType: Prefix
            backend:
              service:
                name: pizza-backend-service
                port:
                  number: {{ .Values.service.backend.port }}
{{- end }}
EOF

# Install the Helm chart
helm install pizza-app ./$CHART_NAME

echo "Helm chart created and deployed successfully!"

chmod +x before-instation.sh
./before-instation.sh

helm install sentry sentry-kubernetes/sentry -f values.yaml --namespace sentry

