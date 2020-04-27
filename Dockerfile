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
COPY csr-configurations/* ./
RUN cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# generate certificates for identities in the PKI who need them:
# - kubernetes (api server)
# - kube-proxy
# - worker (kubelet)
# - kube-scheduler
# - kube-controller-manager
# - service accounts
COPY gencert.sh .

# all certificates without hostnames
RUN ./gencert.sh admin && \
      ./gencert.sh kube-controller-manager && \
      ./gencert.sh kube-proxy && \
      ./gencert.sh kube-scheduler && \
      ./gencert.sh service-account

# the worker(s) and API server(s) specify their hostnames
RUN cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      -hostname=worker,127.0.0.1 \
      worker-csr.json | cfssljson -bare worker

RUN cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      -hostname=127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local \
      kubernetes-csr.json | cfssljson -bare kubernetes
