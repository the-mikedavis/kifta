# Kifta

Kifta is a set of docker images derived from on Ubuntu 18.04 that run a
single-pod Kubernetes control plane. Kifta is configured to only be accessed
on-pod (via `127.0.0.1:6443`).

Kifta is an example of running Kubernetes in Kubernetes (colloqially known as
Kubeception).

> Never run a Kifta cluster in production. This project is for education
> purposes only.

Kifta was built with the instructions found in the popular education repository
[kelseyhightower/kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

Kifta generates new PKI certificates on every build of the image. These
certificates - as well as their keys - are stored in plain text in the
filesystem.

## More Detail

Kifta runs the control plane of Kubernetes in a pod. This means that:

- `etcd` the distributed database from CoreOS
- `kube-controller-manager`
- `kube-scheduler`
- `kube-apiserver`

are each run as containers in the same pod. When running, the control plane
looks like so:

```console
$ kubectl get deployments
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
kifta   1/1     1            1           25h
$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
kifta-668c75b76-85xlt   4/4     Running   1          25h
```

where `4/4` means that each of the above listed components is currently
running as a container in the pod `kifta-668c75b76-85xlt`.

The configurability of the control plane makes this easy: the control plane is
nothing more than a distributed set of microservices pieced together by
configuration.

## What I Wanted from Kifta

While running the control plane is relatively easy, running workes ("machines"
or pods or containers running `kubelet`, `kube-proxy`, and a container runtime)
is very difficult. Running a container runtime inside a container runtime is
beyond my current abilities ;)

If one could run the workers also inside the pod, one could run an entire
Kubernetes cluster as a pod inside another Kubernetes cluster. The economy of
doing so would enable accessible on-demand or per-user Kubernetes clusters
within an organization or school.

## What can you do with kifta?

If you `kubectl exec <kifta pod>`, you'll be able to run `kubectl` commands
against the control plane: mainly `Secret`s. Because the `etcd` at-rest
encryption is turned off, `kifta` can provide a good lab for uncovering
secret data in vulnerable clusters (assuming access to the compromised control
plane).

## I want to run Kifta

Assuming you already have `kubectl` configured with access to an existing real
cluster:

```console
$ kubectl apply -f https://raw.githubusercontent.com/the-mikedavis/kifta/master/deployment.yaml
```

Interacting with the control plane running there:

```console
$ POD_NAME=$(kubectl get pods -l app=kifta -o jsonpath="{.items[0].metadata.name}")
$ kubectl exec -it $POD_NAME -c kube-apiserver
> kubectl get componentstatus --kubeconfig /var/kifta/admin.kubeconfig
```

(In the example above, `kube-apiserver` is chosen as the container to run from,
but you may interact with the control plane from any of the containers, or
even modify `deployment.yaml` to run a container just for interacting with the
others.)
