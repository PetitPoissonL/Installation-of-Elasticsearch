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

Perform the following steps on the server `hadoop102`:

1. Download the version 7.8.0 of Elasticsearch from the website:
```
cd /opt/software/
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.8.0-linux-x86_64.tar.gz
```

2. Extract the Archive
```
tar -zxvf elasticsearch-7.8.0-linux-x86_64.tar.gz -C /opt/module/
```

3. Rename ES in the `/opt/module` directory:
```
mv elasticsearch-7.8.0 es7
```

## Step 3: Configure Elasticsearch

Perform the following steps on the server `hadoop102`:

1. Modify the ES configuration file `elasticsearch.yml`:
```
cd config/
vim elasticsearch.yml
```
```
#Modify the following content
cluster.name: my-es
node.name: node-1
bootstrap.memory_lock: false
network.host: 0.0.0.0
http.port: 9200
transport.tcp.port: 9301
discovery.seed_hosts: ["hadoop102:9301", "hadoop103:9301"]
cluster.initial_master_nodes: ["node-1", "node-2", "node-3"]
discovery.zen.fd.ping_timeout: 1m
discovery.zen.fd.ping_retries: 5
```
2. Environment startup optimization:

Elasticsearch runs within a JVM and by default, it starts with 1GB of memory. However, when the server is running on a Linux virtual machine with limited memory allocation, you can reduce the JVM's memory. In production environments with typically 31GB of memory as standard, you may need to increase this memory allocation.

```
vim jvm.options
```
```
-Xms512m
-Xmx512m
```

3. Distribute ES:
```
cd /opt/module/
xsync es7
```

4. Modify the node names on `hadoop103` and `hadoop104`:
on the server `hadoop103`:
```
cd /opt/module/es/config/
vim elasticsearch.yml
```
```
node.name: node-2
```
on the server `hadoop104`:
```
cd /opt/module/es/config/
vim elasticsearch.yml
```
```
node.name: node-3
```

## Step 4: Cluster startup script
Create 'es.sh' in the `~/bin/` directory
