# Getting started with RCP

This repository helps you submit jobs to the [RCP CaaS cluster](https://wiki.rcp.epfl.ch/en/home/CaaS).

The RCP Wiki gives you a [Quick start guide](https://wiki.rcp.epfl.ch/home/CaaS/Quick_Start), which you can follow. However, we provide a base image for bindcraft (and hopefully more later) meaning that you do not necessarily have to build your own image. The setup guide does not cover building your own image and defers to the RCP wiki. 

> [!IMPORTANT]
> **Network requirement**: You must be on the EPFL WiFi or connected to the VPN.

> [!IMPORTANT]
> Using the cluster creates costs. Please be mindful of the resources you use. **Do not forget to stop your jobs when not used!**

Content overview:
- [Setup Guide](#setup-guide)
  - [1. Setup Tools on Your Machine](#1-setup-tools-on-your-machine)
  - [2. Login to the Cluster](#2-login-to-the-cluster)
  - [3. Credentials](#3-ldap-credentials)
  - [4. (Optional) Weights and biases, HuggingFace, Claude and Codex](#4-optional-weights-and-biases-huggingface-claude-and-codex)
  - [5. (Optional) Symlinks](#5-optional-symlinks)
- [Launching jobs](#launching-jobs)
- [Using VS Code](#using-vs-code)

## Setup Guide

#### 1. Setup Tools on Your Machine

#### Install kubectl

Download and install kubectl v1.30.11 (matching the cluster version):

```bash
# macOS with Apple Silicon
curl -LO "https://dl.k8s.io/release/v1.30.11/bin/darwin/arm64/kubectl"

# Linux (AMD64)
# curl -LO "https://dl.k8s.io/release/v1.30.11/bin/linux/amd64/kubectl"

# Install
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo chown root: /usr/local/bin/kubectl
``` 

See https://kubernetes.io/docs/tasks/tools/install-kubectl/ for other platforms.

#### Setup kubeconfig

Download the kube config file to `~/.kube/config`:

```bash
curl https://wiki.rcp.epfl.ch/public/files/kube-config.yaml -o ~/.kube/config && chmod 600 ~/.kube/config
```

#### Install run:ai CLI

Download and install the run:ai CLI:

```bash
# macOS with Apple Silicon
wget --content-disposition https://rcp-caas-prod.rcp.epfl.ch/cli/darwin

# Linux (replace 'darwin' with 'linux')
# wget --content-disposition https://rcp-caas-prod.rcp.epfl.ch/cli/linux

# Install
chmod +x ./runai
sudo mv ./runai /usr/local/bin/runai
sudo chown root: /usr/local/bin/runai
```

### 2. Login to the Cluster

#### Login to run:ai

```bash
runai login
```

#### Verify access

```bash
# List available projects
runai list projects

# Set your default project
runai config project make-dlai-{GASPARD-USERNAME}
```

#### Verify Kubernetes connection

```bash
kubectl get nodes
```

You should see the RCP cluster nodes listed.

## Launching jobs

### Interactive

Jobs can be started interactively with the following command:
```bash
runai submit --name JOB_NAME -i registry.rcp.epfl.ch/dlai-bindcraft/bindcraft:latest -g 1 --existing-pvc claimname=make-dlai-scratch,path=/scratch --interactive --attach
```

Once inside the container you can activate the conda environment and start a bindcraft job:
```bash
conda activate BindCraft
ln -s /scratch/data/params/ .
python -u ./bindcraft.py --settings '/scratch/{YOUR_GASPARD}/path/to/target.json' --filters './settings_filters/default_filters.json' --advanced './settings_advanced/default_4stage_multimer.json'
```

### Background

If you want jobs to run in the background you can run with:
```bash
runai submit --name JOB_NAME -i registry.rcp.epfl.ch/dlai-bindcraft/bindcraft:latest -g 1 --existing-pvc claimname=make-dlai-scratch,path=/scratch -- conda activate BindCraft && ln -s /scratch/data/params/ . && python -u ./bindcraft.py --settings '/scratch/{YOUR_GASPARD}/path/to/target.json' --filters './settings_filters/default_filters.json' --advanced './settings_advanced/default_4stage_multimer.json'
```

### Job management

```bash
runai list jobs
runai describe job <name>
runai logs <name>
runai logs <name> --pod <name>-0-<n>   # specific retry pod
runai delete job <name>
```

## Credits

This guide builds upon https://github.com/LTS4/rcp-lts4-guidelines/blob/update-from-rcp/README.md
