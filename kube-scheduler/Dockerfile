FROM docker.pkg.github.com/the-mikedavis/kifta/base:v1 AS base

WORKDIR /etc/kubernetes/config/

RUN wget -q --https-only \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-scheduler" && \
  chmod +x kube-scheduler && \
  mv kube-scheduler /usr/local/bin/

COPY kube-scheduler.yaml .

EXPOSE 10251

CMD /usr/local/bin/kube-scheduler \
  --config=/etc/kubernetes/config/kube-scheduler.yaml \
  --v=2
