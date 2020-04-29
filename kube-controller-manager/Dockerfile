FROM docker.pkg.github.com/the-mikedavis/kifta/base:v1 AS base

WORKDIR /var/kifta

RUN wget -q --https-only \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-controller-manager" && \
  chmod +x kube-controller-manager && \
  mv kube-controller-manager /usr/local/bin/

EXPOSE 10257

CMD /usr/local/bin/kube-controller-manager \
  --address=0.0.0.0 \
  --cluster-cidr=10.200.0.0/16 \
  --cluster-name=kubernetes \
  --cluster-signing-cert-file=/var/kifta/ca.pem \
  --cluster-signing-key-file=/var/kifta/ca-key.pem \
  --kubeconfig=/var/kifta/kube-controller-manager.kubeconfig \
  --leader-elect=true \
  --root-ca-file=/var/kifta/ca.pem \
  --service-account-private-key-file=/var/kifta/service-account-key.pem \
  --service-cluster-ip-range=10.32.0.0/24 \
  --use-service-account-credentials=true \
  --authentication-kubeconfig=/var/kifta/kube-controller-manager.kubeconfig \
  --v=2
