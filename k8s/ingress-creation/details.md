# Day 9 — Ingress Controller + Service Exposure (AKS)

Today you will expose an application **properly** from AKS using an **Ingress Controller**. This is a **core production skill** and the natural next step after PVCs and Deployments.

We will do this in a **clean, industry-standard way**:

* NGINX Ingress Controller
* ClusterIP Service
* Ingress resource
* No TLS yet (HTTPS comes Day 10)

---

## Day 9 objectives

By the end of Day 9, you will be able to:

1. Explain **Service vs Ingress** clearly
2. Install **NGINX Ingress Controller** on AKS
3. Expose an app using:

   * Deployment
   * ClusterIP Service
   * Ingress
4. Access your app via an **external IP**
5. Understand how this fits with Terraform & CI/CD

---

# 1) Mental model (do not skip)

### Kubernetes Service

A Service:

* Exposes pods **inside** the cluster
* Stable virtual IP
* Types:

  * `ClusterIP` (internal only)
  * `NodePort` (low-level, not recommended)
  * `LoadBalancer` (cloud LB per service)

### Ingress

Ingress:

* HTTP/HTTPS routing layer
* One **external IP**
* Routes traffic to multiple Services
* Requires an **Ingress Controller**

👉 **Ingress = HTTP router**
👉 **Service = pod selector + stable endpoint**

---

# 2) Why NGINX Ingress Controller

NGINX Ingress is:

* Most widely used
* Fully supported on AKS
* Well-documented
* Production-proven

AKS does **not** install it by default.

---

# 3) Install NGINX Ingress Controller (AKS)

### Step 1 — Add the Helm repo

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

### Step 2 — Install the controller

```bash
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

Wait until it is ready:

```bash
kubectl get pods -n ingress-nginx
```

You should see `controller` pod running.

---

# 4) Get the external IP

```bash
kubectl get svc -n ingress-nginx
```

Look for:

```
ingress-nginx-controller   LoadBalancer   <EXTERNAL-IP>
```

This IP is your **single entry point**.

---

# 5) Create a demo application (HTTP server)

Create `k8s/day9-app.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: app
spec:
  type: ClusterIP
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
```

Apply:

```bash
kubectl apply -f k8s/day9-app.yaml
kubectl -n app get deploy,svc
```

---

# 6) Create an Ingress resource

Create `k8s/day9-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 80
```

Apply:

```bash
kubectl apply -f k8s/day9-ingress.yaml
kubectl -n app get ingress
```

---

# 7) Access your application

Take the external IP from step 4 and open in browser:

```text
http://<EXTERNAL-IP>/
```

You should see the **NGINX welcome page**.

🎉 You have now exposed an app correctly using Ingress.

---

# 8) Verify traffic flow (important understanding)

Traffic path:

```
Client
  ↓
Azure LoadBalancer (created by ingress controller)
  ↓
NGINX Ingress Controller
  ↓
Service (ClusterIP)
  ↓
Pod
```

Only **one** public IP is used for many apps.

---

# 9) Common mistakes (and why you avoided them)

| Mistake                                 | Why it’s wrong          |
| --------------------------------------- | ----------------------- |
| Using Service type LoadBalancer per app | Expensive, not scalable |
| Using NodePort                          | Low-level, insecure     |
| Exposing pods directly                  | Breaks Kubernetes model |
| Skipping Ingress                        | Limits routing & TLS    |

You did it correctly.

---

# 10) Cleanup (optional)

```bash
kubectl -n app delete ingress web-ingress
kubectl -n app delete deploy web
kubectl -n app delete svc web
```

Ingress controller stays installed.

---

## Day 9 completion checklist

1. Installed NGINX Ingress Controller
2. Observed external IP
3. Deployed app + ClusterIP Service
4. Created Ingress resource
5. Accessed app via browser
6. Understood Service vs Ingress clearly

---

