# Scenario 1 — Pods Running But Application is Unreachable

### 1. What are the first 3 kubectl commands you run to start investigating?

1.  `kubectl get svc -A`: To check if the Service exists, has an external IP (if LoadBalancer), and is mapped to the correct port.
2.  `kubectl describe ingress <ingress-name>`: To verify the Ingress rules, backend service mapping, and if the Ingress controller has successfully allocated an address.
3.  `kubectl get endpoints <service-name>`: To confirm if the Service has successfully discovered the running Pods. If empty, the selector in the Service doesn't match the Pod labels.

### 2. Which Kubernetes resources would you check first — Deployment, Service, Ingress, or NSG? Walk through your reasoning.

1.  **Service / Endpoints**: I start here because it bridges the network to the pods. If there are no endpoints, the traffic has nowhere to go.
2.  **Ingress**: If Service/Endpoints look good, the issue is likely at the entry point. I'd check for misconfigured paths, hostnames, or TLS issues.
3.  **NSG (Network Security Group)**: If K8s resources are perfect, the blocker is likely external. Azure NSGs often block traffic on port 80/443 if not explicitly allowed, or the LoadBalancer IP might be restricted.
4.  **Deployment**: Since pods are "Running", this is the least likely culprit, but I'd check container logs if the app itself is failing to respond to probes.

### 3. How would you test whether the problem is at the pod level, the service level, or the ingress/network level?

-   **Pod Level**: Use `kubectl port-forward pod/<pod-name> 8080:<pod-port>` and try to access it locally. If it works, the pod is healthy.
-   **Service Level**: Run a temporary pod in the cluster (`kubectl run -it --rm debug --image=curlimages/curl -- sh`) and try to `curl` the service name. If this works, internal routing is fine.
-   **Ingress/Network Level**: If the previous two work, but the external URL doesn't, the issue is with the Ingress controller, DNS, or Azure-level networking (LB/NSG).

### 4. Name two Azure-specific things that could cause this even when the Kubernetes resources all look correct.

1.  **NSG rules on the Node Subnet**: The Network Security Group associated with the AKS node subnet might be blocking inbound traffic on the ports assigned to the LoadBalancer.
2.  **Azure Load Balancer Health Probes**: If the LB health probe (which checks the NodePort) is failing because the application doesn't respond on the expected path/port, Azure will stop routing traffic to that node entirely.
