# Deployment
Now that you have downloaded or compiled the Brane binaries, we can deploy the instance so we can connect to it.

Currently, there are two different modes of deployment:
- Deploy the framework on a single Docker engine. We refer to this as _local deployment_, and it means that the control plane of the framework runs on a single node.
- Deploy the framework on multiple nodes with Docker engines. We refer to this as a _distributed deployment_ or a _kubernetes deployment_, and it means that the control plane of the framework runs on multiple nodes.

Note that this different only applies to the Brane control plane, not its jobs. Regardless of how you deploy it, you are still able to run jobs remotely on different machines.


## Choosing the right node(s)
Before we begin, you'll have to choose the proper location to run the framework on.

If you plan to run the framework as a local deployment, make sure you have Docker installed to support the instance containers. Other container runtimes should work too, although you then cannot use `make.sh`'s start and stop commands.

Additionally, remember that, if you are connecting to remote sites (i.e., any site that is not `local` and points to off-site machines) requires that the node where the control plane runs is accessible from the internet. This means that any devices behind a NAT (such as a home router) are not suitable (unless proper port-forwarding is used; check the [appendix](../appendix/specifications.md) for a list of ports used by Brane).

Finally, if you intent to launch Brane locally, make sure that there are no Kubernetes clusters running on that node. It seems that the separate Docker network that Brane uses tends to mess-up the networking of the Kubernetes cluster; so instead, deploy brane as a distributed deployment on that cluster instead.


## Local deployment
If you've chosen a suitable node for a local deployment, make sure that you prepare the binaries (as described in the [Get binaries](./get-binaries.md) chapter) and have a `config/infra.yml` and (optionally) a `config/secrets.yml` defined so the framework knows where it may run jobs (as described in the [Defining infrastructures](./infrastructures.md) chapter).

> <img src="../assets/img/info.png" alt="drawing" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note: for now, we recommend you to copy the entire source repository to the target node in addition to just the binaries, as the `make.sh` script assumes that it can compile from source whenever it wants. However, this process will be much more streamlined in the near future.

Additionally, don't forget to install the [prerequisite dependencies](./get-binaries.md#prerequisites) on the node where you will run the framework as well.

Then, you can open up a terminal and navigate to the repository's main folder. From there, run:
```bash
./make.sh start-instance
```
to start the instance using the images you have previously compiled.

Note that, in true Makefile-style, the `make.sh` script will attempt to build the framework first if it hasn't done so already. If you want to build the framework in development mode, you may supply `--dev` here as well to tell the framework to build that way.

Eventually, the `make.sh` script will return, and the Brane images should have started. Be aware though, that for a minute or so, both `brane-api` and `brane-log` will appear to be failing; this is because the Scylla database is still booting in that period. Once the database is up-and-running, the services should be able to connect, and they will stop crashing.

To stop the Brane instance again, you can run:
```bash
./make.sh stop-instance
```
This will completely tear the instance down, removing all containers too. This means that any state changes (i.e., pushing packages) will have to be done again once you start the instance.


## Distributed deployment
Alternatively to a local deployment, you may also deploy Brane on a Kubernetes cluster. This will require some additional setup steps, to both the machine where you built the framework and will deploy it from (the _build machine_) and the Kubernetes cluster where Brane will run (the _cluster_, with a _master node_ and one or more _worker nodes_).


### Cluster: change NodePort range
As can be seen in the [specification](../appendix/specifications.md), there are a lot of canonical ports for the Brane framework to connect to. However, because the framework deploys itself using a NodePort, and the standard port range does not include the Brane ports, we would like to change this to allow Brane to run on proper ports.

> <img src="../assets/img/warning.png" alt="drawing" width="16" style="margin-top: 2px; margin-bottom: -2px"/> This is a bad-practise workaround. However, the framework is not yet configured to run in a LoadBalancer (like it should), and so, for now, it will have to run as a NodePort and you will have to change the Brane port range.

To change the default port, perform the following steps:
- Edit (as root) `/etc/kubernetes/manifests/kube-apiserver.yaml` on your control node.
- Search the file for a line that says "`- --service-cluster-ip-range=<range>`" (excluding quotes).
- Add the following line below it with the same indentation:
  ```
  - --service-node-port-range=6379-50055
  ```
  Also note the `- --`, which requires the space in between the first and second dash and no dash after the third.
- Save the file.

You have now opened ports 6379 through 50055 for use of NodePort services. Both of this range's bounds are Brane ports, so you shouldn't make it any more restrictive than this range.

Once you save the file, the Kubernetes cluster should automatically rebuild the appropriate pods. This might take a while. However, if you feel you're getting stuck, we would recommend rebooting your cluster nodes so they are restarted once again.


### Cluster: create the `brane-control` namespace
Next, the Brane control plane expects to run inside a dedicated namespace called `brane-control`. Thus, the next step is to create this namespace in your cluster.

> <img src="../assets/img/info.png" alt="drawing" width="16" style="margin-top: 3px; margin-bottom: -3px"/> More accurately, it's only `make.sh` that requires this to be the case. In the future, it will be adapted to accept any namespace; but for now, it is hardcoded to `brane-control`.

To do so, run:
```bash
kubectl create namespace brane-control
```
and you should now have a namespace called `brane-control`.

You can either access this account from your build machine with an administration config, but this is usually bad practise. Instead, you can follow [this](https://computingforgeeks.com/restrict-kubernetes-service-account-users-to-a-namespace-with-rbac/) tutorial to create a user account that only has access to a particular namespace.


### Cluster: prepare persistent volumes
A few Brane services (`brane-drv`, `brane-job`, `brane-plr` and `aux-minio`) require a persistent storage to be setup in your cluster that they can reach regardless of their container state.

There are two separate volumes that should be available:
- A `brane-data` volume, which contains the database describing the `/data` volume in containers. Only the `aux-minio` service uses this.
- A `brane-config` volume, which contains the `infra.yml` and `secrets.yml` file that define the infrastructures where Brane may run. Defining them as persistent storage allows real-time adaptation, without the need to recompile the framework on every change.

If you already have (a) StorageClass(es) and matching PersistentVolumes that define these volumes, then you can pass the classes' names to the `make.sh` script to let Brane use them (see [below](#conclusion-deploying-the-instance)). Otherwise, you should create two new classes with matching volumes to do so.

For simplicity, we will prepare four local PersistentVolumes (since local volumes don't seem to be able to be shared across PODs), which simply mount a folder on a node. However, this limits the availability of the volume to only that node, meaning that the brane services will be bound to a single node. For production environments, you should definitely use a better storage method to make the directories available across the cluster.

First, create two new StorageClasses (one for each type of storage Brane uses, to make sure they don't overlap), which defines the type of the storage that the cluster provides:
```bash
# Run on your control node
# Define the StorageClass for the data
cat <<EOT | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: brane-data-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOT

# Define the StorageClass for the config
cat <<EOT | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: brane-config-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOT
```
You can replace the name of the StorageClass with whatever you like. If you do, then you will have to manually specify it every time you run `make.sh` to deploy your cluster. Also, don't forget to replace it in the next few commands as well if you decide to change the names.

Next, create at the four PersistentVolumes (one per service). Because this determines where the services requiring this volume will run, you should choose different nodes for the volumes (to try to spread the load).

To create the volumes, replace the values in triangular brackets (`<>`) and run the following commands:
```bash
# Run on your control node
# Define the PersistentVolume for the data volume
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: brane-data-pv
spec:
  volumeMode: Filesystem
  capacity:
    storage: 100Mi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  # Replace if you named your StorageClass differently
  storageClassName: brane-data-storage
  local:
    path: "<path/to/data/dir>"
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - <node name as in "kubectl get nodes">
EOF

# Define three PersistentVolumes for the config volume (we use a for-loop)
for i in 01 02 03; do
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: brane-config-pv-$i
    spec:
      volumeMode: Filesystem
      capacity:
        storage: 100Mi
      accessModes:
        # Note that this one differs from the other config
      - ReadOnlyMany
      persistentVolumeReclaimPolicy: Retain
      # Replace if you named your StorageClass differently
      storageClassName: brane-config-storage
      local:
        path: "<path/to/config/dir>"
      nodeAffinity:
        required:
          nodeSelectorTerms:
          - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
              - <node name as in "kubectl get nodes">
EOF
done
```
The `<path/to/data/dir>` that you provide will contain the persistent part of the shared `data/` folder in the Brane packages, and should thus be an empty folder that you're not using for something else. The same applies for the `<path/to/config/dir>` value, except that this should point to a folder that already contains an `infra.yml` and a `secrets.yml`. Then, `<node name as in "kubectl get nodes">` should be the name of the worker node where you want to create a PersistentVolume. Finally, you can also change the name of this resource as you like (the one under `metadata`).

You now have PersistentVolumes that the Brane services may use to store or read out-of-container data. If your StorageClasses have different names than the default ones, be sure to note them down for use when calling `make.sh`.


### Cluster: prepare for registry connection
Part of Brane is a Docker image registry (the `aux-registry` service), which usually only stores the package images. In the case of a distributed deployment, though, it is also used to store the service images so the Kubernetes cluster can access them from all of its nodes.

However, by default, Docker expects a registry to provide SSL encryption to its connection. That means that, without any preparation, Kubernetes will fail to pull the service images (or push/pull package images) with errors along the lines of:
```
Got HTTP response to HTTPS client
```
There are two ways forward to fix this:
1) You can provide the registry with an SSL certificate for your cluster.
   > <img src="../assets/img/info.png" alt="drawing" width="16" style="margin-top: 3px; margin-bottom: -3px"/> The documentation describing this will be added soon.

2) You can also tell the Docker daemon to not expect an SSL connection anymore.

   > <img src="../assets/img/warning.png" alt="drawing" width="16" style="margin-top: 2px; margin-bottom: -2px"/> This is a bad-practise workaround. However, for testing or private purposes, this is a lot easier than obtaining an SSL certificate. Don't use this method in a production environment, though.

   To do so, execute the following steps on every node in your cluster:
    - Edit (as root) `/etc/docker/daemon.json`
    - Make sure that the root of the JSON file contains this following:
      ```json
      {
          ...

          "insecure-registries": ["<cluster_ip>:50050"]

          ...
      }
      ```
      (The dots indicate potential other stuff; you should not copy them to the file).
    - Save the file
    - Restart the Docker engine using:
      ```bash
      sudo systemd restart docker
      ```
      > <img src="../assets/img/warning.png" alt="drawing" width="16" style="margin-top: 2px; margin-bottom: -2px"/> Note that this will likely distrupt your cluster for a moment. Wait until all nodes are up-and-running again before continuing.


### Build machine: prepare for registry connection
Similarly to the cluster, your registry will have to be able to connect to the Brane image repository as well.

If you use a pubicly signed SSL certificate to initialize the registry in the [Cluster: prepare for registry connection](#cluster-prepare-for-registry-connection) section, then you shouldn't have to change anything, as the Docker engine will automatically use the publicly available certificate.

Otherwise, do one of the following:
1) If you use a self-signed certificate, be sure to add it to your machine's trusted certficates:
   > <img src="../assets/img/info.png" alt="drawing" width="16" style="margin-top: 3px; margin-bottom: -3px"/> The documentation describing this will be added soon.

2) If you disabled the Docker daemon to use SSL for your registry, do the same on your build machine too:
    - Edit (as root) `/etc/docker/daemon.json`
    - Make sure that the root of the JSON file contains this following:
      ```json
      {
          ...

          "insecure-registries": ["<cluster_ip>:50050"]

          ...
      }
      ```
      (The dots indicate potential other stuff; you should not copy them to the file).
    - Save the file
    - Restart your local Docker engine using:
      ```bash
      sudo systemd restart docker
      ```


### Build machine: download Kubernetes configuration file
Your build machine will have to have direct access to (the `brane-control` namespace in) the target Kubernetes cluster.

To obtain this, download a Kubernetes configuration file from the cluster. If you've created a new user config specifically for access only to the `brane-control` namespace, you should use that one. Otherwise, you can use the administrator one (`/etc/kubernetes/admin.conf`, though this is bad practise!).

We will assume that the config file is available on your cluster under `~/brane.conf`. However, if you use another location or name, replace that path with the correct one in subsequent commands.

First, create the folder for the config file if it does not exist yet:
```bash
mkdir -p ~/.kube
```
Next, download the config file from the cluster:
```bash
scp <cluster_addr>:~/brane.conf ~/.kube/config
```
where `<cluster_addr>` should be replaced with the address of your cluster's control node (or another node if that's where you created the configuration file). Also note that we rename the downloaded file to `config` under the `~/.kube` directory on your build machine, so you shouldn't have to replace any more names in subsequent commands.

Finally, make sure that the file has the correct permissions by running:
```bash
chown $(id -u):$(id -g) ~/.kube/config
chmod 644 ~/.kube/config
```

To verify that you can access the cluster, run
```bash
kubectl version
```
and check that it doesn't fail to connect and returns a proper version number for the cluster (the `Server Version`).


### Conclusion: deploying the instance
If you have completed all of the above steps, both your build machine and Kubernetes cluster are ready to deploy Brane.

The deployment is completely handled by `make.sh`. Like for a local deployment, it will probably first try to build the framework if you haven't done so already. Then, it will deploy the registry, push the images, and deploy the other services.

To start the instance on your cluster, run:
```bash
./make.sh start-instance-k8s
```

If you have given a custom domain name for your cluster, run the `make.sh` script with the `--cluster-domain` option:
```bash
./make.sh start-instance-k8s --cluster-domain <domain_name>
```

If your StorageClasses have any name other than the default ones (`brane-data-storage` and `brane-config-storage`), then your should start the instance with:
```bash
./make.sh start-instance-k8s --data-storage-name <data_name>  --config-storage-name <config_name>
```

Similarly to the local deployment, you can also let the command build the framework in development mode by specifying the `--dev` flag.

Deploying the framework might take some time, as pushing the images may be slow on consumer internet connections (especially if you're using the development images). The services may take some time to come online as well.

You may stop the instance by using a similar (but different) command as with a local deployment:
```bash
./make.sh stop-instance-k8s
```
Optionally, you can provide the `--keep-registry` flag to prevent the registry from being destroyed so the service and package images will be cached on the next start. Note, though, that if you do, you _still_ have to push the packages every time you start the instance. This is because the `brane-api` service contains the package list, and that will be wiped even in the registry is kept.

> <img src="../assets/img/info.png" alt="drawing" width="16" style="margin-top: 3px; margin-bottom: -3px"/> If you want to re-start your cluster after stopping it, don't forget to manually release the PersistentVolumes. You may do this by deleting them (`kubectl delete pv <name>`) and then re-creating them as specified in the [Cluster: prepare persistent volumes](#cluster-prepare-persistent-volumes) section.


## Next
Finally, you have a running instance of the Brane framework. To use it, you should move to the [Brane: The User Guide](https://wiki.enablingpersonalizedinterventions.nl/user-guide) book to learn how to use it from a user perspective.

Alternatively, you can add more infrastructures by starting at the [next chapter](../infrastructures/introduction.md), which provides documentation about the `infra.yml` and `secrets.yml` file and the kind of infrastructures that the Brane framework supports.
