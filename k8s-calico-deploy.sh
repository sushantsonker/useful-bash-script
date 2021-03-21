Prompt if this is an AKS/EKS/AWS-IAAS/Azure-IAAS/On-prem Cluster
If non-AKS
# Check if files below are present tigera-operator.yaml(in current directory), tigera-prometheus-operator.yaml(in current directory), ~/.docker/config.json, custom-resources-cni-only.yaml  are present
If AKS
# Check if files below are present tigera-operator.yaml(in current directory), tigera-prometheus-operator.yaml(in current directory), ~/.docker/config.json, custom-resources-cni-aks-only.yaml,  are present
kubectl create -f tigera-operator.yaml
kubectl create -f tigera-prometheus-operator.yaml
kubectl create secret generic tigera-pull-secret --from-file=.dockerconfigjson=~/.docker/config.json --type=kubernetes.io/dockerconfigjson -n tigera-operator

# For non-aks clusters, run
kubectl create -f custom-resources-cni-only.yaml
# For aks clusters, run
kubectl create -f custom-resources-cni-aks-only.yaml
watch kubectl get tigerastatus
kubectl get tigerastatus
NAME                  AVAILABLE   PROGRESSING   DEGRADED   SINCE
apiserver             True        False         False      3d11h
calico                True        False         False      3d11h

# Wait until the apiserver shows a status of Available
# Prompt if portworx is installed. If not exit.
# Create storage class
Check if tigera-elasticsearch sc is present and attribute is set to retain
If not, warn and then delete existing tigera-elasticsearch sc and recreate with 
kubectl create -f elasticsearch-storage-sc-portworx.yaml

# For non-aks clusters, run
kubectl create -f custom-resources-enterprise-only.yaml
# For aks clusters, run
kubectl create -f custom-resources-enterprise-aks-only.yaml
kubectl create -f license.yaml
watch kubectl get tigerastatus
# Wait until all the components shows a status of Available
 kubectl get tigerastatus
NAME                  AVAILABLE   PROGRESSING   DEGRADED   SINCE
apiserver             True        False         False      3d11h
calico                True        False         False      3d11h
compliance            True        False         False      3d11h
intrusion-detection   True        False         False      3d11h
log-collector         True        False         False      3d11h
log-storage           True        False         False      3d11h
manager               True        False         False      3d11h

kubectl create -f tigera-policies.yaml
Prompt for log collector hostname or IP
# Enable fluentd logs
kubectl edit LogCollector tigera-secure (add the spec section)

----sample config below----
apiVersion: operator.tigera.io/v1
kind: LogCollector
metadata:
  name: tigera-secure
spec:
  additionalStores:
    syslog:
      # Syslog endpoint, in the format protocol://host:port
      endpoint: udp://<logcollector-host-name>:514
      # Packetsize is optional, if messages are being truncated set this
      packetSize: 2048
      logTypes:
      - Flows
----sample config end----

# Set aggregation to 0
kubectl edit felixconfigurations default

----Add the lines below to spec section----
  flowLogsFileAggregationKindForAllowed: 0
  flowLogsFileAggregationKindForDenied: 0
  flowLogsFlushInterval: 1s
  dnsLogsFlushInterval: 10s

----Add Lines complete----

# To set UI access and get access token
kubectl create sa tigera-admin -n tigera-manager
kubectl create clusterrolebinding tigera-admin --clusterrole tigera-network-admin --serviceaccount tigera-manager:tigera-admin
kubectl get secret -n tigera-manager $(kubectl get serviceaccount tigera-admin -n tigera-manager -o jsonpath='{range .secrets[*]}{.name}{"\n"}{end}' | grep token) -o go-template='{{.data.token | base64decode}}' && echo
write the output to a token-password.txt file
# To get password for kibana (user:elastic)
kubectl -n tigera-elasticsearch get secret tigera-secure-es-elastic-user -o yaml |  awk '/elastic:/{print $2}' | base64 --decode
write the output to a kibana-password.txt file
# To enable UI, follow instructions in commands-tigera-ui-ingress.txt

# To start UI using portforwarding (set context, run the command locally and open browser at https://localhost:9443)
kubectl port-forward -n tigera-manager service/tigera-manager 9443:9443


# Run helm charts for network policies
