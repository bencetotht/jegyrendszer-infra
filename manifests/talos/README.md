# Manual Cluster Setup
## 1. Install Cilium CNI
```bash
helm install cilium cilium/cilium --version 1.18.1 --namespace kube-system --values 1-cilium-values.yaml
```
### Using Cilium as LB
Apply pools:
```bash
kubectl apply -f 1-cilium-pools.yaml
```
Annotate the Traefik service with:
```yaml
metadata:
  annotations:
    io.cilium/lb-ipam-ips: 192.168.88.105
```
### If using MetaLB as LB
Install MetalLB LoadBalancer
```bash
# install chart
helm install metallb metallb/metallb --version 0.15.2 --namespace metallb-system
# apply config
kubectl apply -f 2-metallb-pools.yaml --namespace metallb-system
```
## 3. Install Traefik LoadBalancer
```bash
helm install traefik traefik/traefik -n traefik-system --create-namespace --values 3-traefik-values.yaml
```
## 4. Install Longhorn Storage Provider
```bash
helm install longhorn longhorn/longhorn -n longhorn-system --create-namespace --values 4-longhorn-values.yaml
```