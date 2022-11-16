export ANSIBLE_RETRY_FILES_ENABLED=0
export ANSIBLE_HOST_KEY_CHECKING=False
VARS?=resources/ocp_vars.yml
export VARYML=$(VARS)
ANSIBLE_CMD:=./ansible_launcher.sh

help: 			## Show this help
	@echo -e '$$ [VARS=$(VARS)] make <recipe>'
	@fgrep -h "##" Makefile | fgrep -v "fgrep" | sed -r 's/(.*)(:)(.*)(##)(.*)/\1:\5/' - | column -s: -t | sed -e 's/##//'
	@$(MAKE) -s vars

# Secret recipes
coffee: vars hosts ocp01 ocp03 ocp04 ocp05 ocp06 ocp10 ocp11 
sync:
	rsync -azP --exclude=.git/ ./ root@192.168.35.80:/root/ocp-4-installer
nuke: vars clean_cluster clean_infra
test: vars hosts
	$(ANSIBLE_CMD) lib/helpers/test.yml

##
## Setup
vars:
	@printf "\033[36mUsing variables $$VARYML \033[0m\n"
hosts:
	@ansible localhost -m template -a "src=templates/ocp4_hosts.j2 dest=ocp4_hosts" -e @$(VARYML) -o 2>/dev/null
ocp00: vars				## SETUP | INFRA | Setup local machine
	$(ANSIBLE_CMD) lib/ocp_00_setup_local_machine.yml
ocp01: vars hosts			## SETUP | INFRA | Create NM, LB1, LB2 VMs
	$(ANSIBLE_CMD) lib/ocp_01_infra_create_vms.yml
ocp02: vars hosts			## SETUP | INFRA | Register VMs
	$(ANSIBLE_CMD) lib/ocp_02_infra_register_vms.yml || echo "Ignoring errors"
ocp03: vars hosts	  		## SETUP | INFRA | NM | Install DNS server
	$(ANSIBLE_CMD) lib/ocp_03_infra_install_dns.yml
ocp04: vars hosts			## SETUP | INFRA | NM | Install DHCP - TFTP server
	$(ANSIBLE_CMD) lib/ocp_04_infra_install_dhcp.yml
ocp05: vars hosts			## SETUP | INFRA | NM | Install HTTPD
	$(ANSIBLE_CMD) lib/ocp_05_infra_install_httpd.yml
ocp06: vars hosts			## SETUP | INFRA | NM | Install HAProxy
	$(ANSIBLE_CMD) lib/ocp_06_infra_install_haproxy.yml
ocp07: vars hosts			## SETUP | INFRA | NM | Install NFS
	$(ANSIBLE_CMD) lib/ocp_07_infra_install_nfs_server.yml
ocp10: vars				## SETUP | OCP   | Create ignition files
	$(ANSIBLE_CMD) lib/ocp_10_openshift_create_ignition.yml
ocp11: vars				## SETUP | OCP   | Provision cluster VMs
	$(ANSIBLE_CMD) lib/ocp_11_openshift_provision_cluster.yml
ocp12: vars				## SETUP | OCP   | Deploy Openshift registry VMs using NFS storage
	$(ANSIBLE_CMD) lib/ocp_12_openshift_setup_registry.yml
ocp13: vars				## SETUP | OCP   | Configure infra and ingress nodes with labels and taints
	$(ANSIBLE_CMD) lib/ocp_13_openshift_configure_nodes.yml
ocp14: vars			## SETUP | OCP   | AD | Setup AD
	$(ANSIBLE_CMD) lib/ocp_14_openshift_setup_ad.yml
ocp15: vars				## SETUP | OCP   | AD | Sync admin groups
	$(ANSIBLE_CMD) lib/ocp_15_openshift_sync_admin_group.yml
ocp90: vars				# SETUP | Install Squid proxy
	$(ANSIBLE_CMD) lib/ocp_90_infra_install_squid.yml

add_nodes: vars hosts		## OCP   | add nodes defined under the additional_nodes variable
	$(ANSIBLE_CMD) lib/ocp_17_openshift_add_nodes.yml
delete_nodes: vars vars			## OCP   | delete nodes defined in resources/nodes_to_delete.yml
	$(ANSIBLE_CMD) -e @resources/nodes_to_delete.yml lib/zz_delete_nodes.yml

clean_infra: vars			## CLEAN | Delete infra ressource VMs
	$(ANSIBLE_CMD) lib/zz_delete_infra_vms.yml
clean_cluster: vars			## CLEAN | Delete cluster VMs
	$(ANSIBLE_CMD) lib/zz_delete_openshift_vms.yml


##
## Helpers
approve_csr:				##HELPER | Approve new-node's CSRs
	oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve
mirror_registry: vars			##HELPER | Setup mirror registry using oc adm command, used for disconnected installs
	$(ANSIBLE_CMD) lib/helpers/mirror_registry.yml
pki_csr: vars				##HELPER | PKI | generate csr for ingress and api
	$(ANSIBLE_CMD) lib/pki/generate_csr.yml
setup_ingress_api: vars		##HELPER | PKI | setup ingress and master api certificates to the cluster
	$(ANSIBLE_CMD) lib/pki/setup_ingress_api.yml
reboot_infra_vms: vars 		##HELPER | INFRA | Reboot infrastructure servers
	$(ANSIBLE_CMD) lib/helpers/reboot_infra_vms.yml


##
## Post install
postinstall_logging: vars			## POST  | Deploy logging solution
	$(ANSIBLE_CMD) lib/postinstall/01_logging.yml
postinstall_monitoring: vars		## POST  | Deploy monitoring solution
	$(ANSIBLE_CMD) lib/postinstall/02_monitoring.yml
postinstall_openid: vars			## POST  | Deploy Openid config
	$(ANSIBLE_CMD) lib/postinstall/03_openid.yml
	oc adm add-cluster-role-to-user cluster-admin admin@adlere.fr
postinstall_nsx_tags: vars				## POST  | NSX | Tag nodes on the NSX manager for NCP 3.0.1
	$(ANSIBLE_CMD) lib/postinstall/nsx_tag_nodes.yml
postinstall_nsx: vars					## POST  | NSX | Fix multus-cni configuration for NCP 3.0.1
	$(ANSIBLE_CMD) lib/postinstall/nsx_ncp.yml


# Demos
servicemesh:
	cd openshift/servicemesh && ./servicemesh_demo.sh
