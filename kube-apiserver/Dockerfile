FROM kifta/base:latest AS base

WORKDIR /var/lib/kubernetes

RUN wget -q --https-only \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-apiserver" && \
  chmod +x kube-apiserver && \
  mv kube-apiserver /usr/local/bin/

COPY encryption-config.yaml .

EXPOSE 6443

CMD /usr/local/bin/kube-apiserver \
  --allow-privileged=true \
  --apiserver-count=1 \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/var/log/audit.log \
  --authorization-mode=Node,RBAC \
  --bind-address=0.0.0.0 \
  --client-ca-file=/var/kifta/ca.pem \
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --etcd-cafile=/var/kifta/ca.pem \
  --etcd-certfile=/var/kifta/kubernetes.pem \
  --etcd-keyfile=/var/kifta/kubernetes-key.pem \
  --etcd-servers=https://127.0.0.1:2379 \
  --event-ttl=1h \
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \
  --kubelet-certificate-authority=/var/kifta/ca.pem \
  --kubelet-client-certificate=/var/kifta/kubernetes.pem \
  --kubelet-client-key=/var/kifta/kubernetes-key.pem \
  --kubelet-https=true \
  --runtime-config=api/all \
  --service-account-key-file=/var/kifta/service-account.pem \
  --service-cluster-ip-range=10.32.0.0/24 \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=/var/kifta/kubernetes.pem \
  --tls-private-key-file=/var/kifta/kubernetes-key.pem \
  --v=2
