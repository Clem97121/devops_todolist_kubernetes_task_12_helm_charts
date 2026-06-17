# Django ToDo List Validation Instructions

This document provides step-by-step guidance on how to validate the Kubernetes deployment of the Django ToDo list application, configured via a Helm chart (`todoapp`) and an integrated sub-chart (`mysql`) inside a `kind` cluster.

---

## Prerequisites

Before validating, ensure you have the following CLI tools installed:
* **Docker**
* **kind**
* **kubectl**
* **helm**

---

## Deployment & Verification Steps

### 1. Execute the Bootstrap Script
Run the automated initialization script from the root of the repository to spin up the cluster, apply configurations, manage dependencies, and deploy the charts:
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```
### 2. Validate Nodes, Labels, and Taints
Verify that the kind cluster nodes are correctly labeled and that the node intended for the database has been properly tainted with app=mysql:NoSchedule:

```bash
kubectl get nodes --show-labels
kubectl describe nodes -l app=mysql | grep Taints
```
Expected Output: The node matching the selector should display Taints: app=mysql:NoSchedule.

### 3. Verify Helm Release and Dependencies
Check if the Helm release was deployed successfully and verify that the mysql sub-chart was successfully built as a dependency:

```bash
helm list -A
```

### 4. Validate Running Resources
Confirm that all pods, services, horizontal pod autoscalers (HPA), persistent volume claims (PVC), and ingress resources are running inside the namespace defined in your values.yaml (e.g., todoapp):

```bash
# Replace 'todoapp' if you altered the namespace configuration in values.yaml
kubectl get all,pvc,hpa,ing,sa -n todoapp
```

### 5. Validate Environment Variables Setup
Verify that secrets were dynamically mapped using the template range loops inside the application deployment:

```bash
kubectl env deployment/todoapp-release -n todoapp
```

### 6. Verify Log Output
The automated validation capture file output.log is generated in the root directory. Ensure it contains the cluster state dump:

```bash
cat output.log
```