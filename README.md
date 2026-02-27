# vind-with-mesh

This Terraform project allows an user create a local Kubernetes Cluster using the [vCluster-in-Docker Stack](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/experimental/docker) (vind) and configuring optionally one between Istio with Ambient Mode or Istio with Sidecar Injection.

The following steps are performed within the project:

* A local cluster composed by a Control-Plane node and one or more Worker-Nodes is bootstrapped 
* The Ports 80, 443 and 15021 are exposed through LoadBalancer
* A `kubeconfig` file is created locally in the project folder
* The namespace `istio-system` with the basic Istio services is created
* The namespace `istio-ingress` with the configuration of a Kubernetes Gateway (in case of ambient mode) or an Istio Gateway (in case of sidecar-injection mode)

## Requirements

The following tools are required for this project:

* `docker` (up and running)
* `terraform` (1.6+) / `opentofu` (1.6+)
* `helm` (3.0+)
* `vind` (0.32.0+)

`vind` must be configured to use the Docker driver:

```sh
vcluster use driver docker
```

## Creating the Cluster

Please see the `examples`, corresponding to the type of cluster that you want to bootstrap (with istio or cilium).

You can create a cluster from the root path of this repository, by typing one of the following commands:

`make create-cluster-ambient` for a KIND cluster with the Istio service mesh components in ambient mode

`make create-cluster-sidecar` for a KIND cluster with the Cilium service mesh components in sidecar-injection mode

### Initialization issues

You might receive the message

```sh
Could not load kernel module br_netfilter: exit status 1. If node join fails, run: sudo modprobe overlay && sudo modprobe bridge && sudo modprobe br_netfilter
```

All you need to do is to load the kernel modules and try again:

```sh
sudo modprobe overlay 
sudo modprobe bridge 
sudo modprobe br_netfilter
```

### Running multiple clusters on the same host

Thanks to vCluster, it is possible to run multiple clusters on the same host, you need to customize the configuration of the cluster (located under `./modules/vind-cluster`), so a specific Kubernetes Context and Endpoint is created.