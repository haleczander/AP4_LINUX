FROM ubuntu:latest

WORKDIR /tmp

COPY install_dir .

RUN apt-get update && apt-get install -y dos2unix sudo
RUN dos2unix installer.sh
RUN chmod +x installer.sh

