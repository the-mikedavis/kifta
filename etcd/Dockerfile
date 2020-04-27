FROM kifta/base:latest AS base

WORKDIR /etc/etcd

RUN cp /var/kifta/ca.pem /var/kifta/kubernetes.pem /var/kifta/kubernetes-key.pem .

RUN wget -q --https-only \
  "https://github.com/etcd-io/etcd/releases/download/v3.4.0/etcd-v3.4.0-linux-amd64.tar.gz" && \
  tar xf etcd-v3.4.0-linux-amd64.tar.gz 2>/dev/null && \
  mv etcd-v3.4.0-linux-amd64/etcd* /usr/local/bin/ && \
  mkdir -p /var/lib/etcd

COPY encryption-config.yaml .

EXPOSE 2379 2380

ENV ETCDCTL_API=3

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
