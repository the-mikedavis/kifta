#! /bin/bash

kubectl config set-cluster kifta \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=$1.kubeconfig

kubectl config set-credentials system:$1 \
  --client-certificate=$1.pem \
  --client-key=$1-key.pem \
  --embed-certs=true \
  --kubeconfig=$1.kubeconfig

kubectl config set-context default \
  --cluster=kifta \
  --user=system:$1 \
  --kubeconfig=$1.kubeconfig

kubectl config use-context default \
  --kubeconfig=$1.kubeconfig
