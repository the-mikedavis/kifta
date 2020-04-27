# initial image is Ubuntu 18.04 (server)
FROM ubuntu:bionic

RUN apt-get update -yq && apt-get install -yq wget

# download cloudflare PKI toolchain "cfssl"
RUN wget -q --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssl \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssljson && \
  chmod +x cfssl cfssljson && \
  mv cfssl cfssljson /usr/local/bin/

# download kubectl, the kubernetes client command line utility
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/
