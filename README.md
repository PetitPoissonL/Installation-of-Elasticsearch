# Installation of Elasticsearch for [Spark real-time project](https://github.com/PetitPoissonL/Spark_Streaming_Real_Time)
This guide provides step-by-step instructions for installing and configuring Elasticsearch on three servers: `hadoop102`, `hadoop103`, and `hadoop104`.

## Prerequisites

- Ensure each server (hadoop102, hadoop103, hadoop104) is running a compatible Linux distribution.
- Java 8 must be installed on all servers.
- Cluster distribution script [xsync](https://github.com/PetitPoissonL/Cluster-distribution-script-xsync/tree/main)
- Sudo or root access on each server.

## Step 1: Modify operating system parameters
By default, Elasticsearch is in single-node access mode. However, we will configure it to allow application servers to access it over the network. At this point, Elasticsearch may encounter errors or even fail to start due to the default low-end configuration for single-node mode. Therefore, we need to adjust some server restrictions here to support higher concurrency.
Perform the following steps on the server `hadoop102`:
1. Change the maximum number of files that Elasticsearch is allowed to open to 65536:
```
sudo vim /etc/security/limits.conf
```
```
#Append the following content at the end of the file:
* soft nofile 65536
* hard nofile 131072
* soft nproc 2048
* hard nproc 65536
```
Distribute the file:
```
scp -r /etc/security/limits.conf root@hadoop103:/etc/security/
scp -r /etc/security/limits.conf root@hadoop104:/etc/security/
```
2. Change the number of virtual memory areas a process can have:
```
sudo vim /etc/sysctl.conf
```
```
#Append the following content at the end of the file:
vm.max_map_count=262144
```
Distribute the file:
```
scp -r /etc/sysctl.conf root@hadoop103:/etc/
scp -r /etc/sysctl.conf root@hadoop104:/etc/
```
3. Change the maximum allowed number of threads to 4096 (no need to modify if the operating system is CentOS 7.x)：
```
sudo vim /etc/security/limits.d/20-nproc.conf
```
```
#Modify the following content
* soft nproc 4096
```
Distribute the file:
```
scp -r /etc/security/limits.d/20-nproc.conf root@hadoop103:/etc/security/limits.d/
scp -r /etc/security/limits.d/20-nproc.conf root@hadoop104:/etc/security/limits.d/
```

## Step 2: Install Elasticsearch
