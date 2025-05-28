# Continuous Integration Project 
The goal of this project is to automate a CI (continuous integration) process to be triggered whenever a commit is pushed to a remote repository.
A continuous integration pipeline is created and deployed using Jenkins.

## Installations in Local Machine
This project requires following programs:
- java
- Jenkins
- Docker

### 1. Clone this repo

```bash
mkdir -p ~/simulation_ws/src
git clone git@github.com:kailash197/cp24_ros1_ci.git
mv cp24_ros1_ci ros1_ci
```


### 2. Install Jenkins
[Terminal 1]
```bash
cd ~/simulation_ws/src/ros1_ci
./start_jenkins.sh
```
newgrp docker
xhost +local:root  # For GUI applications


### 3. Pull source code and Build


## Run Project

### 1. Make changes and commit


### 2. Create a PR


### 3. Monitor Jenkins webpage 