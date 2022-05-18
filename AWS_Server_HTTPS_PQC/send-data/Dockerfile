FROM ubuntu:20.04 AS builder
# FROM debian:bullseye AS builder

# Set timezone
ENV TZ=Asia/Taipei
ENV DEBIAN_FRONTEND=noninteractive

## ------ Original Setting ------
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-setuptools  
#--no-install-recommends

RUN pip3 install --no-binary Pillow requests
RUN pip3 install Pillow 

# Copy files from the local storage to a destination in the Docker image
WORKDIR /
ADD . /
RUN chmod 777 /*

# HTTPS port 
EXPOSE 443

# Run python script
CMD python3 send_data.py

STOPSIGNAL SIGTERM
