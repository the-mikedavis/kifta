# Kifta

Kifta is a docker image derived from on Ubuntu 18.04 that runs a single-node
Kubernetes cluster, running the worker and controller processes in the same
container. Kifta clusters can only be accessed from localhost (on-container).

> Never run a Kifta cluster in production. This project is for education
> purposes only.

Kifta was built with the instructions found in the popular education repository
[kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

Kifta generates new PKI certificates on every build of the image. These
certificates - as well as their keys - are stored in plain text in the
filesystem.
