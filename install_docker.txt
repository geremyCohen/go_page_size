# Step-by-Step Docker and Ubuntu 24.04 Container Installation Guide

## 1. Update Package Lists
```bash
sudo apt-get update
```

## 2. Install Docker Dependencies
```bash
sudo apt-get install -y ca-certificates curl gnupg
```

## 3. Add Docker's Official GPG Key
```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

## 4. Add Docker Repository to APT Sources
```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

## 5. Update Package Lists with Docker Repository
```bash
sudo apt-get update
```

## 6. Install Docker Engine
```bash
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 7. Verify Docker Installation
```bash
docker --version
```

## 8. Add User to Docker Group (to run Docker without sudo)
```bash
sudo usermod -aG docker $USER
```
Note: You may need to log out and log back in for this change to take effect.

## 9. Pull Ubuntu 24.04 Container Image
```bash
docker pull ubuntu:24.04
```

## 10. Verify Ubuntu Image was Downloaded
```bash
docker images
```

## 11. Test the Ubuntu 24.04 Container
```bash
docker run --rm ubuntu:24.04 cat /etc/os-release
```

## Using the Ubuntu 24.04 Container

### Run a single command in the container:
```bash
docker run --rm ubuntu:24.04 <command>
```

### Start an interactive shell session:
```bash
docker run -it --rm ubuntu:24.04 bash
```

### Run a container with a mounted volume:
```bash
docker run -it --rm -v /path/on/host:/path/in/container ubuntu:24.04 bash
```

### Run a container with network port mapping:
```bash
docker run -it --rm -p 8080:80 ubuntu:24.04 bash
```
