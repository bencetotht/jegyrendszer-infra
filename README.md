# Infrastructure and GitOps

This repository stores all the manifests that are actively in production in a self-hosted kubernetes cluster.
All reconciliations are managed by [FluxCD](https://fluxcd.io/).
## Sites hosted by us:

- Erettsegi site: [irodalomerettsegi.hu](https://irodalomerettsegi.hu)
- Portfolio site: [bnbdevelopment.hu](https://bnbdevelopment.hu)
- Status site: [status.bnbdevelopment.hu](https://status.bnbdevelopment.hu)
- Documentation site: [docs.bnbdevelopment.hu](https://docs.bnbdevelopment.hu)

## Cluster Architecture
```bash
BNB-CLUSTER
├── BNBDEVELOPMENT/
│   ├── BNBDEVELOPMENT Documentation
│   └── BNBDEVELOPMENT Portfolio Page
├── Certmanager/
│   ├── Certmanager
│   └── Ingresses
├── ErettsegiSite/
│   ├── irodalomerettsegi.hu
│   └── Erettsegi Site Redis Cache
├── Keycloak/
│   └── HA Keycloak
├── Monitoring/
│   ├── Prometheus/
│   │   └── ScrapeConfigs
│   ├── Grafana/
│   │   └── Ingress
│   └── Loki
├── Default/
│   └── Flux Repositories
├── Traefik-System/
│   └── External Ingresses/
│       ├── Proxmox
│       └── Portainer
├── Flux-System/
│   └── Flux System Components
└── Utility/
    └── Reflector
```
## Infrastructure
![infra](./.docs/infra-diagram.png)
---
Developed & maintained by [Bence Toth](https://github.com/bencetotht) and [Bence Gyurus](https://github.com/BenceGyurus)
