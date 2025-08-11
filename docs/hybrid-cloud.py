from diagrams import Diagram, Cluster, Edge

from diagrams.onprem.network import HAProxy, Traefik
from diagrams.onprem.compute import Server

from diagrams.k8s.compute import Pod
from diagrams.k8s.network import Service
from diagrams.k8s.ecosystem import Helm

from diagrams.aws.storage import S3
from diagrams.aws.network import SiteToSiteVpn
from diagrams.aws.engagement import SES

from diagrams.generic.place import Datacenter
from diagrams.generic.compute import Rack

from diagrams.saas.cdn import Cloudflare

OUTPUT_FILENAME = "hybrid_cluster_diagram"

with Diagram("Hybrid Kubernetes Cluster Architecture", filename=OUTPUT_FILENAME, show=False, direction="TB", graph_attr={
    "fontsize": "16",
    # "bgcolor": "transparent",
    "pad": "0.5"
}):
    
    # Client Layer
    with Cluster("Client Access Layer", graph_attr={"style": "rounded", "color": "blue"}):
        user = Rack("External Clients")
    
    # Edge Layer
    with Cluster("Public Edge / CDN", graph_attr={"style": "rounded", "color": "orange"}):
        cf_tunnel = Cloudflare("Cloudflare Tunnel\n(HTTPS Termination)")
    
    # On-Premises Infrastructure
    with Cluster("On-Premises Infrastructure", graph_attr={"style": "rounded", "color": "green"}):
        haproxy_onprem = HAProxy("HAProxy Load Balancer\n(Primary)")
        
        with Cluster("Local Kubernetes Cluster", graph_attr={"style": "rounded", "color": "darkgreen"}):
            with Cluster("Control Plane Nodes", graph_attr={"style": "rounded", "color": "forestgreen"}):
                local_control_1 = Server("k8s-control-plane-1")
                local_control_2 = Server("k8s-control-plane-2")
            
                traefik_onprem = Traefik("Traefik")
    
    # Network Connectivity
    with Cluster("Network Connectivity", graph_attr={"style": "rounded", "color": "purple"}):
        site_to_site_vpn = SiteToSiteVpn("Tailscale VPN\n(Secure Tunnel)")
    
    # Cloud Infrastructure
    with Cluster("AWS Cloud Infrastructure (Failover)", graph_attr={"style": "rounded", "color": "red"}):
        haproxy_cloud = HAProxy("HAProxy Load Balancer\n(Failover)")
        
        with Cluster("Cloud Kubernetes Cluster", graph_attr={"style": "rounded", "color": "darkred"}):
            with Cluster("Control Plane Nodes", graph_attr={"style": "rounded", "color": "indianred"}):
                cloud_control_1 = Server("k8s-control-plane-1")
                cloud_control_2 = Server("k8s-control-plane-2")
            
                traefik_cloud = Traefik("Traefik")
        
        with Cluster("Cloud Services", graph_attr={"style": "rounded", "color": "coral"}):
            s3 = S3("Cloud / Backup Storage")
            ses = SES("Email Service")

    # Connection Flow
    # Client to Edge
    user >> Edge(label="HTTPS Traffic", style="bold", color="blue") >> cf_tunnel
    
    # Edge to Load Balancers
    cf_tunnel >> Edge(label="TLS Termination\n& Proxy", style="bold", color="orange") >> haproxy_onprem
    cf_tunnel >> Edge(label="TLS Termination\n& Proxy", style="bold", color="orange") >> haproxy_cloud
    
    # VPN Connection between sites
    haproxy_onprem >> Edge(style="dashed", color="purple") >> site_to_site_vpn
    haproxy_cloud >> Edge(style="dashed", color="purple") >> site_to_site_vpn
    
    # Load Balancer to Control Planes
    haproxy_onprem >> Edge(style="solid", color="green") >> local_control_1
    haproxy_onprem >> Edge(style="solid", color="green") >> local_control_2
    
    haproxy_cloud >> Edge(style="solid", color="red") >> cloud_control_1
    haproxy_cloud >> Edge(style="solid", color="red") >> cloud_control_2
    
    # Control Planes to Workloads
    local_control_1 >> Edge(style="dotted", color="darkgreen") >> traefik_onprem
    local_control_2 >> Edge(style="dotted", color="darkgreen") >> traefik_onprem
    
    cloud_control_1 >> Edge(style="dotted", color="darkred") >> traefik_cloud
    cloud_control_2 >> Edge(style="dotted", color="darkred") >> traefik_cloud
