# Repositories
```bash
helm repo add longhorn https://charts.longhorn.io
helm repo add traefik https://traefik.github.io/charts
```
# Install main packages
## Install Metallb
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
```
## Install Traefik
```bash
helm install traefik traefik/traefik -n traefik-system --create-namespace --values traefik.yaml
```
## Install Longhorn
```bash
helm install longhorn longhorn/longhorn -n longhorn-system --create-namespace --values longhorn.yaml
```
# Install additional packages
## Install automated updates
```bash
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/crd.yaml
```