# initial image is Ubuntu 18.04 (server)
FROM ubuntu:bionic


## Generate certificates and configure component kubeconfigs

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

# make kubeconfig files for
# - kube-controller-manager
# - kubelet
# - kube-proxy
# - kube-scheduler
# - admin

COPY genkubeconfig.sh ./

RUN ./genkubeconfig.sh worker && \
      ./genkubeconfig.sh kube-proxy && \
      ./genkubeconfig.sh kube-controller-manager && \
      ./genkubeconfig.sh kube-scheduler && \
      ./genkubeconfig.sh admin


## Configure `etcd`

RUN wget -q --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.4.0/etcd-v3.4.0-linux-amd64.tar.gz" && \
  tar xf etcd-v3.4.0-linux-amd64.tar.gz && \
  mv etcd-v3.4.0-linux-amd64/etcd* /usr/local/bin/ && \
  mkdir -p /etc/etcd /var/lib/etcd && \
  cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd

COPY encryption-config.yaml .

CMD /usr/local/bin/etcd \
  --name kifta \
  --cert-file=/etc/etcd/kubernetes.pem \
  --key-file=/etc/etcd/kubernetes-key.pem \
  --peer-cert-file=/etc/etcd/kubernetes.pem \
  --peer-key-file=/etc/etcd/kubernetes-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --peer-client-cert-auth \
  --client-cert-auth \
  --initial-advertise-peer-urls https://127.0.0.1:2380 \
  --listen-peer-urls https://127.0.0.1:2380 \
  --listen-client-urls https://127.0.0.1:2379 \
  --advertise-client-urls https://127.0.0.1:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster kifta=https://127.0.0.1:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
