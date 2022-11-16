# Requirements for the bastion server 
```
#Repo EPEL
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# Git, Make, Ansible
yum --releasever=7.6 update -y
subscription-manager repos --enable=rhel-7-server-ansible-2.8-rpms
yum install git make ansible-2.8.7-1.el7ae -y
```

# Installing OCP - 4
- Create or update the default resources/ocp_vars.yml.<br />
- Specify the yaml config file to use `export VARS=./resources/ocp_vars.yml`<br />
- Use `make <recipe name>` to execute the corresponding task. <br />
```
$ [VARS=resources/ocp46_vars.yml] make <recipe>
help                     Show this help

 Setup
ocp00                    SETUP | INFRA | Setup local machine
ocp01                    SETUP | INFRA | Create NM, LB1, LB2 VMs
ocp02                    SETUP | INFRA | Register VMs
ocp03                    SETUP | INFRA | NM | Install DNS server
ocp04                    SETUP | INFRA | NM | Install DHCP - TFTP server
ocp05                    SETUP | INFRA | NM | Install HTTPD
ocp06                    SETUP | INFRA | NM | Install HAProxy
ocp07                    SETUP | INFRA | NM | Install NFS
ocp10                    SETUP | OCP   | Create ignition files
ocp11                    SETUP | OCP   | Provision cluster VMs
ocp12                    SETUP | OCP   | Deploy Openshift registry VMs using NFS storage
ocp13                    SETUP | OCP   | Configure infra and ingress nodes with labels and taints
ocp14                    SETUP | OCP   | AD | Setup AD
ocp15                    SETUP | OCP   | AD | Sync admin groups
clean_infra              CLEAN | Delete infra ressource VMs
clean_cluster            CLEAN | Delete cluster VMs
add_nodes                OCP   | add nodes defined under the additional_nodes variable
delete_nodes             OCP   | delete nodes defined in resources/nodes_to_delete.yml

 Helpers
approve_csr             HELPER | Approve new-node's CSRs
mirror_registry         HELPER | Setup mirror registry using oc adm command, used for disconnected installs
pki_csr                 HELPER | PKI | generate csr for ingress and api
setup_ingress_api       HELPER | PKI | setup ingress and master api certificates to the cluster
reboot_infra_vms        HELPER | INFRA | Reboot infrastructure servers

 Post install
postinstall_logging      POST  | Deploy logging solution
postinstall_prometheus   POST  | Deploy prometheus
postinstall_openid       POST  | Deploy Openid config
postinstall_nsx_tags     POST  | NSX | Tag nodes on the NSX manager for NCP 3.0.1
postinstall_nsx          POST  | NSX | Fix multus-cni configuration for NCP 3.0.1
```


# OpenShift Clients

The OpenShift client `oc` simplifies working with Kubernetes and OpenShift
clusters, offering a number of advantages over `kubectl` such as easy login,
kube config file management, and access to developer tools. The `kubectl`
binary is included alongside for when strict Kubernetes compliance is necessary.

To learn more about OpenShift, visit [docs.openshift.com](https://docs.openshift.com)
and select the version of OpenShift you are using.

## License

These tools are the property of Adlere 
usage is restricted to the final customer only.

Distribution for Consulting purposes is prohibited
without written authorization.

© 2020 Adlere ALL RIGHTS RESERVED