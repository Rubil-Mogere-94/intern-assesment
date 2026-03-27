# Scenario 1 – Pods Running But Application Unreachable

## 1. What do you think the most likely root cause is?

- **Networking misconfiguration** at the Service, Ingress, or NSG level.
- The pods are healthy, but the traffic is not reaching them because of a missing Service selector, wrong port mapping, or an Azure NSG blocking the load balancer’s health probes.

## 2. What steps / commands would you run to investigate?

First, three `kubectl` commands:
1. `kubectl get svc -n <namespace>` – check if the Service exists and has an external IP.
2. `kubectl describe svc <service-name>` – verify selectors, ports, and events.
3. `kubectl get endpoints <service-name>` – confirm the Service is pointing to the pods.

## 3. Which Kubernetes resources would you check first — Deployment, Service, Ingress, or NSG? Walk through your reasoning.

I would check in this order:

1. **Service** – because the error is “connection timeout”, which suggests the traffic is not reaching the pods at all. The Service is the main entry point.
2. **Ingress / Load Balancer** – if the Service is `LoadBalancer` or there is an Ingress, the external URL might be misconfigured.
3. **NSG (Azure specific)** – after confirming Kubernetes resources are correct, I’d check if the Azure Network Security Group attached to the AKS node pool allows traffic from the internet to the NodePort or load balancer IP.

I check the Deployment last because pods are already `Running`, so it’s less likely to be the application itself.

## 4. How would you test whether the problem is at the pod level, the service level, or the ingress/network level?

- **Pod level**: `kubectl port-forward pod/<pod-name> <local-port>:<container-port>` and try to access locally. If that works, the pod itself is fine.
- **Service level**: `kubectl run -it --rm test --image=busybox -- wget -O- http://<service-name>.<namespace>.svc.cluster.local:<port>` – test inside the cluster. If this works, the Service is routing correctly.
- **Ingress/network level**: If the service test works but external access fails, the problem is likely the Ingress or cloud‑specific network (NSG, firewall).

## 5. Name two Azure-specific things that could cause this even when the Kubernetes resources all look correct.

1. **NSG rules on the AKS node subnet** – AKS creates a network security group for the node pool. If it doesn’t allow inbound traffic from the internet to the NodePort range (30000-32767) or to the load balancer IP, the connection will timeout.
2. **Azure Load Balancer health probes** – if the health probe (for a `LoadBalancer` service) fails because the probe path is not configured or the target port is wrong, the load balancer won’t forward traffic to the nodes.





