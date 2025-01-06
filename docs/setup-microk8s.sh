#!/bin/bash
#This is the shebang line that tells the system to use /bin/bash to execute the script.

# Updates the local package list from the repositories. This ensures that the latest versions of packages are available before installing new software.
sudo apt update 

# Installs MicroK8s via snap (a package management system for Linux).
#--classic: Allows the package to access system resources that are restricted by default (necessary for MicroK8s).
sudo snap install microk8s --classic

# Adds the current user ($USER) to the microk8s group so that the user can run MicroK8s commands without sudo.
sudo usermod -a -G microk8s $USER #sudo usermod -a -G microk8s mariam

# Creates the ~/.kube directory (if it doesn’t already exist). This directory stores Kubernetes configuration files needed to use kubectl.
mkdir -p ~/.kube

#Changes the ownership of the .kube directory to the current user to ensure proper permissions.
sudo chown -R $USER ~/.kube #sudo chown -R mariam ~/.kube

#reloads user groups to apply permissions changes
newgrp microk8s

# Waits until the MicroK8s cluster is fully ready before continuing. This avoids issues where the cluster is not yet initialized.
microk8s status --wait-ready

# Enable necessary addons
microk8s enable dns # Enables DNS for internal service discovery in Kubernetes.
microk8s enable dashboard # Enables the Kubernetes web-based dashboard for visualizing cluster resources.
microk8s enable storage #Enables dynamic storage provisioning within the cluster.
microk8s enable registry #Enables a built-in private Docker registry for local container images.

# Adds an alias for kubectl in your ~/.bashrc file:
#After this, running kubectl will automatically run microk8s kubectl, so you don’t need to type microk8s kubectl every time.
echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc

# Reloads the .bashrc file to apply the changes
source ~/.bashrc

# Writes the Kubernetes configuration (config) file for kubectl to 
# ~/.kube/config, allowing the kubectl CLI to communicate with the MicroK8s cluster
microk8s config > ~/.kube/config

echo "MicroK8s installation completed!"
echo "Please run: source ~/.bashrc"
