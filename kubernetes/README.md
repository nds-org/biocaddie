# Baseline Evaluation with Kubernetes
A more scalable way to run the baseline evaluations in containers as Jobs on a Kubernetes cluster.

# Prerequisites
* A running Kubernetes Cluster
* An accessible Redis instance

NOTE: All of these scripts must be run from the repository root

## Single-Node Kubernetes Cluster
Prerequisites:
* [Git](https://git-scm.com/)
* [Docker](https://www.docker.com/get-docker)


To run a [local Kubernetes cluster with Docker](https://github.com/kubernetes/community/blob/master/contributors/devel/local-cluster/docker.md), you can run the following:
```bash
export K8S_VERSION=$(curl -sS https://storage.googleapis.com/kubernetes-release/release/stable.txt)
export ARCH=amd64
docker run -d \
    --volume=/sys:/sys:rw \
    --volume=/var/lib/docker/:/var/lib/docker:rw \
    --volume=/var/lib/kubelet/:/var/lib/kubelet:rw,shared \
    --volume=/var/run:/var/run:rw \
    --net=host \
    --pid=host \
    --privileged \
    --name=kubelet \
    gcr.io/google_containers/hyperkube-${ARCH}:${K8S_VERSION} \
    /hyperkube kubelet \
        --hostname-override=127.0.0.1 \
        --api-servers=http://localhost:8080 \
        --kubeconfig=/etc/kubernetes/manifests \
        --cluster-dns=10.0.0.10 \
        --cluster-domain=cluster.local \
        --allow-privileged --v=2
```

You can then download the `kubectl` binary for accessing your cluster using the following command:
```bash
export K8S_VERSION=$(curl -sS https://storage.googleapis.com/kubernetes-release/release/stable.txt)
export GOOS=linux
export GOARCH=amd64
curl -sSL "https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/${GOOS}/${GOARCH}/kubectl" > /usr/bin/kubectl
chmod +x /usr/bin/kubectl
```

Verify that everything is working with the following command:
```bash
ubuntu@integration-3:~/biocaddie$ kubectl get nodes
NAME        STATUS    AGE
127.0.0.1   Ready     6m
```

## Multi-Node Kubernetes Cluster
Prerequisites:
* Multiple VMs, or cloud/local resources to provision multiple VMs
* A shared volume mounted to every node (i.e. NFS, GlusterFS, Quobyte, etc)

Options:
* If you already have multiple VMs provisioned, you can bring up a cluster with a single command using [kubeadm](https://kubernetes.io/docs/getting-started-guides/kubeadm/).
* To deploy multiple VMs to AWS, GCE, Azure, OpenStack, or Baremetal, you can use [kargo](https://github.com/kubernetes-incubator/kargo).
* To deploy multiple VMs to your local laptop (development only), you can use [Vagrant](https://coreos.com/kubernetes/docs/latest/kubernetes-on-vagrant.html).
* To deploy multiple VMs in OpenStack at NCSA or SDSC (with varying support for other sites), you can use [ndslabs-deploy-tools](https://hub.docker.com/r/ndslabs/deploy-tools/).
* For more deployment options, check out the [constantly changing list](https://kubernetes.io/docs/setup/pick-right-solution/).

### Deploying Shared File System
<placeholder for instructions on how to more-easily deploy our gluster (yuck) or some equivalent shared NFS mount>

# Setup
Once your cluster is running, you'll need to deploy an instance of Redis using the [`kubectl` command](https://kubernetes.io/docs/tasks/tools/install-kubectl/):
```bash
kubectl create -f ./kubernetes/redis.yaml
```

This will start up an instance of Redis on your cluster. Execute `kubectl get pods` to retrieve the name of the Redis pod:
```bash
ubuntu@integration-3:~/biocaddie$ kubectl get svc
core@biocaddie-master1 ~ $ kubectl get pods
NAME                         READY     STATUS    RESTARTS   AGE
redis-0p8vk                  1/1       Running   0          15d
```

Acquire a shell into this container using `kubectl exec`:
```bash
export REDIS_NAME=$(kubectl get pods | grep redis | grep -v Terminating | awk '{print $1}')
kubectl exec -it ${REDIS_NAME} bash
```

Once you're inside of the Redis container, you should see that your current working directory is `biocaddie` and it already contains the source needed to run the baseline scripts:
```bash
core@biocaddie-master1 ~ $ kubectl exec -it $(kubectl get pods | grep redis | grep -v Terminating | awk '{print $1}') bash
root@redis-0p8vk:~/biocaddie# ls -al kubernetes/
total 38
drwxr-xr-x.  2 redis root  4096 Jun 28 16:34 .
drwxr-xr-x. 18 redis root  4096 Jul 20 16:28 ..
-rw-r--r--.  1 redis root 11626 Jun 27 18:10 README.md
-rwxr-xr-x.  1 redis root   839 Jun 27 18:10 dir-krovetz.sh
-rwxr-xr-x.  1 redis root   814 Jun 27 18:10 dir.sh
-rw-r--r--.  1 redis root   635 Jun 27 18:10 indri.yaml
-rwxr-xr-x.  1 redis root   840 Jun 27 18:10 jm.sh
-rw-r--r--.  1 redis root  1066 Jun 27 18:10 job.yaml
-rwxr-xr-x.  1 redis root   996 Jun 27 18:10 okapi.sh
-rw-r--r--.  1 redis root   803 Jun 27 18:10 redis.yaml
-rwxr-xr-x.  1 redis root  1556 Jun 27 18:37 reindex.sh
-rwxr-xr-x.  1 redis root  1213 Jun 27 18:10 rm3-krovetz.sh
-rwxr-xr-x.  1 redis root  1220 Jun 27 18:10 rm3-stopped.sh
-rwxr-xr-x.  1 redis root  1169 Jun 27 18:10 rm3.sh
-rwxr-xr-x.  1 redis root  1216 Jun 27 18:10 run_all.sh
-rwxr-xr-x.  1 redis root   936 Jun 27 18:10 tfidf.sh
-rwxr-xr-x.  1 redis root   947 Jun 27 18:10 two.sh
-rw-r--r--.  1 redis root   810 Jun 28 16:34 worker.yaml
```

You are now ready to start running the baseline scripts on Kubernetes!

# Running a Baseline Job
To run a given model on a specific `<collection>`-`<topics>` pair, execute the following from the repository root:
```bash
./kubernetes/<model>.sh <topics> <collection>
```

Accepted parameters:
* `<model>`: `dir`, `dir-krovetz`, `jm`, `okapi`, `rm3`, `rm3-krovetz`, `rm3-stopped`, `tfidf`, or `two`
* `<topics>`: `short`, `stopped`, or `orig`
* `<collection>`: `combined`, `train`, or `test`

For example:
```bash
ubuntu@integration-3:~/biocaddie$ ./kubernetes/dir.sh short combined
(integer) 1
(integer) 2
(integer) 3
(integer) 4
(integer) 5
(integer) 6
(integer) 7
job "dir-combined-short" created
Job started - to run multiple workers for this Job in parallel, use "kubectl scale"
```

The following command will list all existing jobs, along with their worker pods:
```bash
ubuntu@integration-3:~/biocaddie$ kubectl get jobs,pods -a
NAME                        DESIRED   SUCCESSFUL   AGE
jobs/dir-combined-short     <none>    0            20s
jobs/rm3-combined-short     <none>    6            1d
jobs/tfidf-combined-short   <none>    2            1d
jobs/two-combined-short     <none>    2            1d

NAME                            READY     STATUS      RESTARTS   AGE
po/dir-combined-short-bfpgx     1/1       Running     0          20s
po/dir-combined-short-g3xpf     1/1       Running     0          20s
po/redis-dp58n                  1/1       Running     0          5d
po/rm3-combined-short-5nsng     0/1       Completed   0          1d
po/rm3-combined-short-743g1     0/1       Completed   0          1d
po/rm3-combined-short-7vh8g     0/1       Completed   0          1d
po/rm3-combined-short-wl5kt     0/1       Completed   0          1d
po/rm3-combined-short-xf4qx     0/1       Completed   0          1d
po/rm3-combined-short-znq89     0/1       Completed   0          1d
po/temp-2077333550-cxl1g        1/1       Running     2          5d
po/tfidf-combined-short-s2cb2   0/1       Completed   0          1d
po/tfidf-combined-short-zsk58   0/1       Completed   0          1d
po/two-combined-short-qqhtw     0/1       Completed   0          1d
po/two-combined-short-s5jn0     0/1       Completed   0          1d
```

NOTE: including `-a` will also list `Completed` pods in the output.

You can then use `kubectl logs -f <pod_name>` to view the logs of a `Running` or `Completed` worker pod.

Once the job has completed, you will see the number of successful replicas under `kubectl get jobs` has been incremented. You should then be able to check the `output/` folder for the output of the baseline runs:
```bash
ubuntu@integration-3:~/biocaddie$ du -h output/
62M	output/tfidf/combined/short
62M	output/tfidf/combined
62M	output/tfidf
50M	output/two/combined/short
50M	output/two/combined
50M	output/two
4.4M	output/dir/combined/orig
4.6M	output/dir/combined/short
8.9M	output/dir/combined
8.9M	output/dir
6.7M	output/jm/combined/orig
7.1M	output/jm/combined/short
14M	output/jm/combined
14M	output/jm
800M	output/rm3/combined/short
800M	output/rm3/combined
800M	output/rm3
934M	output/
```

## Scaling Up a Job
All jobs, by default, run 2 worker replicas to pull work out of the job queue in Redis.

It is easy, however, to tell Kubernetes to run more than 2 workers:
```bash
kubectl scale job <job_name> --replicas=<N>
```

* `<job_name>` is a value from the `NAME` column of `kubectl get jobs`
* `<N>` is a non-negative integer number of worker pods to run concurrently to execute this job

NOTE: Setting `<N>` to 0 effectively pauses a running job.

For example:
```bash
ubuntu@integration-3:~/biocaddie$ kubectl get jobs
NAME                   DESIRED   SUCCESSFUL   AGE
dir-combined-short     <none>    0            31s
ubuntu@integration-3:~/biocaddie$ kubectl get pods
NAME                       READY     STATUS    RESTARTS   AGE
dir-combined-short-k6nks   1/1       Running   0          16s
dir-combined-short-lrzxg   1/1       Running   0          16s
redis-dp58n                1/1       Running   0          5d
temp-2077333550-cxl1g      1/1       Running   2          5d
ubuntu@integration-3:~/biocaddie$ kubectl scale job dir-combined-short --replicas=5
job "dir-combined-short" scaled
ubuntu@integration-3:~/biocaddie$ kubectl get pods
NAME                       READY     STATUS    RESTARTS   AGE
dir-combined-short-h5pvk   1/1       Running   0          4s
dir-combined-short-hz2nj   1/1       Running   0          4s
dir-combined-short-k6nks   1/1       Running   0          31s
dir-combined-short-lrzxg   1/1       Running   0          31s
dir-combined-short-wl9l3   1/1       Running   0          4s
redis-dp58n                1/1       Running   0          5d
temp-2077333550-cxl1g      1/1       Running   2          5d
```

## Running in Bulk
We also provide a `run_all.sh` that has the capability to run multiple baselines in bulk using the same parameters and a similar syntax to the above scripts.

For example, to run `dir.sh` and `jm.sh` against `combined`-`short` and `combined`-`orig`, you could use:
```bash
./kubernetes/run_all.sh "dir jm" "short orig" "combined"
```

For example:
```bash
ubuntu@integration-3:~/biocaddie$ ./kubernetes/run_all.sh "dir jm" "short orig" "combined"
(integer) 1
(integer) 2
(integer) 3
(integer) 4
(integer) 5
(integer) 6
(integer) 7
job "dir-combined-short" created
Job started - to run multiple workers for this Job in parallel, use "kubectl scale"
(integer) 1
(integer) 2
(integer) 3
(integer) 4
(integer) 5
(integer) 6
(integer) 7
job "dir-combined-orig" created
Job started - to run multiple workers for this Job in parallel, use "kubectl scale"
(integer) 1
(integer) 2
(integer) 3
(integer) 4
(integer) 5
(integer) 6
(integer) 7
(integer) 8
(integer) 9
(integer) 10
(integer) 11
job "jm-combined-short" created
Job started - to run multiple workers for this Job in parallel, use "kubectl scale"
(integer) 1
(integer) 2
(integer) 3
(integer) 4
(integer) 5
(integer) 6
(integer) 7
(integer) 8
(integer) 9
(integer) 10
(integer) 11
job "jm-combined-orig" created
Job started - to run multiple workers for this Job in parallel, use "kubectl scale"
ubuntu@integration-3:~/biocaddie$ kubectl get jobs,pods
NAME                        DESIRED   SUCCESSFUL   AGE
jobs/dir-combined-orig      <none>    0            5s
jobs/dir-combined-short     <none>    0            6s
jobs/jm-combined-orig       <none>    0            5s
jobs/jm-combined-short      <none>    0            5s
jobs/rm3-combined-short     <none>    6            1d
jobs/tfidf-combined-short   <none>    2            1d
jobs/two-combined-short     <none>    2            1d

NAME                          READY     STATUS              RESTARTS   AGE
po/dir-combined-orig-5fkqm    0/1       ContainerCreating   0          5s
po/dir-combined-orig-w5snl    0/1       ContainerCreating   0          5s
po/dir-combined-short-536z9   0/1       ContainerCreating   0          6s
po/dir-combined-short-lglwx   0/1       ContainerCreating   0          6s
po/jm-combined-orig-cbb8t     0/1       ContainerCreating   0          5s
po/jm-combined-orig-r47r6     0/1       ContainerCreating   0          5s
po/jm-combined-short-2g0dw    0/1       ContainerCreating   0          5s
po/jm-combined-short-f01f4    0/1       ContainerCreating   0          5s
po/redis-dp58n                1/1       Running             0          5d
po/temp-2077333550-cxl1g      1/1       Running             2          5d
```

# In Case of Failure
The state of the framework can be reset with a few simple commands:
```bash
kubectl delete jobs --all                        # Stop all running jobs and clean up their worker pods
redis-cli -h ${REDIS_SERVICE_HOST} flushall      # Clear out all work queues in Redis
rm -rf output/*                                  # Delete existing output files
```
