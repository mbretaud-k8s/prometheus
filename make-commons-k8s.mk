#
# You need to define

all:

KEY = $(CURRENT_DIR)/secrets/ssl/tls.key
CERT = $(CURRENT_DIR)/secrets/ssl/tls.crt
POD_NAME=$(shell kubectl get pods --namespace=monitoring --output='json' | jq ".items | .[] | .metadata | select(.name | startswith(\"prometheus-deployment\")) | .name" | head -1 | sed 's/"//g')

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make deploy    - create resources from files"
	@echo "   2. make apply     - apply configurations to the resources"
	@echo "   3. make delete    - delete resources"
	@echo "   4. make describe  - show details of the resources"
	@echo "   5. make get       - display one or many resources"
	@echo "   6. make change	- change namespace"
	@echo ""

###############################################
#
# Deploy
#
###############################################
deploy:
	kubectl create -f prometheus-namespace.yaml --save-config
	@sleep 1
	mkdir -p $(CURRENT_DIR)/secrets/ssl
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $(KEY) -out $(CERT) -subj "/CN=nginxsvc/O=nginxsvc"
	@sleep 1
	kubectl create secret tls nginxsecret --namespace=monitoring --key $(KEY) --cert $(CERT) --save-config
	@sleep 1
	kubectl create -f prometheus-pv.yaml --save-config
	@sleep 1
	kubectl create -f prometheus-pvc.yaml --save-config
	@sleep 1
	kubectl create -f prometheus-cluster-role.yaml --save-config
	@sleep 1
	kubectl create -f prometheus-config-map.yaml --save-config
	@sleep 1
	kubectl create -f prometheus-deployment.yaml --save-config
	@sleep 1
	kubectl create -f prometheus-services.yaml --save-config
	@sleep 1
	kubectl create -f prometheus-ingress.yaml --save-config

###############################################
#
# Apply
#
###############################################
apply:
	kubectl apply -f prometheus-namespace.yaml
	kubectl apply -f prometheus-pv.yaml 
	kubectl apply -f prometheus-pvc.yaml
	kubectl apply -f prometheus-cluster-role.yaml
	kubectl apply -f prometheus-config-map.yaml
	kubectl apply -f prometheus-deployment.yaml
	kubectl apply -f prometheus-services.yaml
	kubectl apply -f prometheus-ingress.yaml

###############################################
#
# Delete
#
###############################################
delete:
	kubectl delete deployment.apps/prometheus-deployment --namespace=monitoring --force --ignore-not-found
	kubectl delete Secret/nginxsecret --namespace=monitoring --force --ignore-not-found
	kubectl delete persistentvolumeclaim/prometheus-pvc-config-volume --namespace=monitoring --force --ignore-not-found
	kubectl delete persistentvolumeclaim/prometheus-pvc-storage-volume --namespace=monitoring --force --ignore-not-found
	kubectl delete persistentvolume/prometheus-pv-config-volume --namespace=monitoring --force --ignore-not-found
	kubectl delete persistentvolume/prometheus-pv-storage-volume --namespace=monitoring --force --ignore-not-found
	kubectl delete clusterrole.rbac.authorization.k8s.io/prometheus --namespace=monitoring --force --ignore-not-found
	kubectl delete ClusterRoleBinding.rbac.authorization.k8s.io/prometheus --namespace=monitoring --force --ignore-not-found
	kubectl delete ConfigMap/prometheus-server-conf --namespace=monitoring --force --ignore-not-found
	kubectl delete service/prometheus-service --namespace=monitoring --force --ignore-not-found
	kubectl delete ingress.networking.k8s.io/prometheus-ingress --namespace=monitoring --force --ignore-not-found
	kubectl delete namespace/monitoring --force --ignore-not-found

###############################################
#
# Describe
#
###############################################
describe:
	@echo "---------------------------"
	kubectl describe namespace/monitoring
	@echo ""

	kubectl describe deployment.apps/prometheus-deployment --namespace=monitoring
	@echo ""

	kubectl describe Secret/nginxsecret --namespace=monitoring
	@echo ""

	kubectl describe persistentvolumeclaim/prometheus-pvc-config-volume --namespace=monitoring
	@echo ""

	kubectl describe persistentvolumeclaim/prometheus-pvc-storage-volume --namespace=monitoring
	@echo ""

	kubectl describe persistentvolume/prometheus-pv-config-volume --namespace=monitoring
	@echo ""

	kubectl describe persistentvolume/prometheus-pv-storage-volume --namespace=monitoring
	@echo ""

	kubectl describe clusterrole.rbac.authorization.k8s.io/prometheus --namespace=monitoring
	@echo ""

	kubectl describe ClusterRoleBinding.rbac.authorization.k8s.io/prometheus --namespace=monitoring
	@echo ""

	kubectl describe ConfigMap/prometheus-server-conf --namespace=monitoring
	@echo ""

	kubectl describe service/prometheus-service --namespace=monitoring
	@echo ""

	kubectl describe ingress.networking.k8s.io/prometheus-ingress --namespace=monitoring
	@echo ""
	@echo "---------------------------"

###############################################
#
# Get
#
###############################################
get:
	@echo "---------------------------"
	kubectl get namespace/monitoring --ignore-not-found
	@echo ""

	kubectl get deployment.apps/prometheus-deployment --namespace=monitoring --ignore-not-found
	@echo ""

	kubectl get Secret/nginxsecret --namespace=monitoring --ignore-not-found
	@echo ""

	kubectl get persistentvolumeclaim/prometheus-pvc-config-volume --namespace=monitoring --ignore-not-found
	@echo ""

	kubectl get persistentvolumeclaim/prometheus-pvc-storage-volume --namespace=monitoring --ignore-not-found
	@echo ""

	kubectl get persistentvolume/prometheus-pv-config-volume --namespace=monitoring --ignore-not-found
	@echo ""

	kubectl get persistentvolume/prometheus-pv-storage-volume --namespace=monitoring --ignore-not-found
	@echo ""

	kubectl get clusterrole.rbac.authorization.k8s.io/prometheus --namespace=monitoring --ignore-not-found
	@echo ""

	kubectl get ClusterRoleBinding.rbac.authorization.k8s.io/prometheus --namespace=monitoring --ignore-not-found
	@echo ""

	kubectl get ConfigMap/prometheus-server-conf --namespace=monitoring --ignore-not-found
	@echo ""

	kubectl get service/prometheus-service --namespace=monitoring --ignore-not-found
	@echo ""

	kubectl get ingress.networking.k8s.io/prometheus-ingress --namespace=monitoring --ignore-not-found
	@echo ""
	@echo "---------------------------"

###############################################
#
# Change Namespace
#
###############################################
change:
	kubectl config set-context $(shell kubectl config current-context) --namespace=monitoring

###############################################
#
# Get logs from the pod
#
###############################################
logs:
	kubectl logs pod/$(POD_NAME) --namespace=monitoring

