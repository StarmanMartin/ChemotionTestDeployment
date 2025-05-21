# ChemotionTestDeployment

Docker container factory for test deployments of Chemotion

**⚠️ Disclaimer
This setup is for testing purposes only and should not be used in production.
Please shut down the container after you're done!**

## 🚀 What is this?

This repository provides a Dockerfile to build a Docker image that allows you to quickly and easily deploy Chemotion ELN in a test environment.
The content is automatically updated after each new commit on the selected branches.

-> __No webhooks are needed!__ It is easy to set up and you do not require any privileges.

The prebuilt image is available on Docker Hub:
```mstarman/chemotion-eln-test:0.0.3```

The included docker-compose.yml file demonstrates how to use the image. Additional services like ChemSpectra or ChemConverter can easily be added to the compose file as needed.

## 🛠️ Getting Started

We provide an installation script that has only been tested on Ubuntu. However, you can also set it up manually in just a few steps

### Ubuntu install script

Run:

```shell
curl -H 'Cache-Control: no-cache' -O https://raw.githubusercontent.com/StarmanMartin/ChemotionTestDeployment/main/setup.sh
chmod +x setup.sh
./setup.sh
```

### By Hand

1. Environment Variables

   * Copy the .env.sample file from this Repo to .env.

   * Make sure to review and update all environment variables, especially PUBLIC_URL.

2. Shared Folder Setup

   * Create a *shared* directory in the same location as your ```docker-compose.yml```.

   * This directory must contain the following subdirectories (you can also clone them from this repo):

```
shared/
├── backup/
├── pullin/
├── restore/
├── shell_script/
└── BRANCH.txt
```

Description of each folder:

* ```backup/```: On every container restart, a database dump will be saved here.

* ```pullin/```: Files in this folder will **overwrite** files in the application on each container restart (useful for overriding config files).

* ```restore/```: Place .spl database dump files here. The **latest** file will be used to initialize the DB (with automatic migration afterwards).

* ```shell_script/```: Any .sh scripts in this folder will be executed on container restart. This is useful for tasks such as installing packages (apt install ...) or updating environment variables.
* 
* ```BRANCH.txt```: The GIT repo branch. This branch is monitored and if there is a new commit, the server is automatically updated.

## Switching Branches

To change the deployed Chemotion branch, modify the first line in the **BRANCH.txt**.