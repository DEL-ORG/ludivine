# Use an Ubuntu image as the base
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common openjdk-17-jdk maven && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io && \
    rm -rf /var/lib/apt/lists/*

# Ensure Docker is available in the PATH
ENV PATH=/usr/bin:$PATH

# Verify installations
RUN java -version && mvn -version && docker --version

