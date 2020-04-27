# initial image is Ubuntu 18.04 (server)
FROM ubuntu:bionic

RUN apt-get update -yq && apt-get install -yq wget openssl

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

# copy over the config for the root Certificate Authority and generate the
# certificate & key
COPY ca-config.json ca-csr.json ./
RUN cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# ditto admin user
COPY admin-csr.json ./
RUN cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      admin-csr.json | cfssljson -bare admin

# ditto "worker" - usually meant to describe a node running kubelet and
# kube-proxy
COPY worker-csr.json ./
RUN cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      -hostname=worker,127.0.0.1 \
      worker-csr.json | cfssljson -bare worker
