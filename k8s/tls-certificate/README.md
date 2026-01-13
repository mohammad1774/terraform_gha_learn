# Day 10 — HTTPS & TLS on AKS with cert-manager (Let’s Encrypt)

Today you will secure your Ingress with **HTTPS** using **cert-manager** and **Let’s Encrypt**. This is the standard, production-grade approach on AKS.

We will do this safely and incrementally:

* Install cert-manager
* Create a ClusterIssuer (Let’s Encrypt **staging** first)
* Issue a TLS certificate
* Attach it to your Ingress
* Verify HTTPS works

---

## Day 10 objectives

By the end of Day 10, you will be able to:

1. Explain how TLS works in Kubernetes (Ingress + cert-manager)
2. Install **cert-manager** correctly
3. Issue a TLS certificate automatically
4. Serve your app over **HTTPS**
5. Know how to move from staging → production and avoid rate limits

---

## 1) TLS mental model (lock this in)

* **Ingress Controller (NGINX)** terminates TLS
* **cert-manager**:

  * Requests certificates from Let’s Encrypt
  * Stores them as Kubernetes **Secrets**
  * Renews them automatically
* **Ingress** references the TLS Secret

Flow:

```
Client → HTTPS → Ingress (NGINX) → Service → Pod
                  ↑
            TLS cert from Secret
                  ↑
            Managed by cert-manager
```

---

## 2) Prerequisites (do these checks)

### 2.1 Ingress controller must exist

```bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

You must have an **external IP**.

### 2.2 You need a DNS name

Let’s Encrypt **cannot** issue certs for raw IPs.

You need a DNS record:

```
your-domain.example.com  →  <INGRESS_EXTERNAL_IP>
```

If you don’t have a domain:

* Use a free subdomain (e.g., DuckDNS), or
* Use your own domain registrar

> You cannot complete Day 10 without DNS.

---

## 3) Install cert-manager

### 3.1 Add Helm repo

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

### 3.2 Install cert-manager (with CRDs)

```bash
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
```

Verify:

```bash
kubectl get pods -n cert-manager
```

You should see:

* `cert-manager`
* `cert-manager-webhook`
* `cert-manager-cainjector`

All must be **Running**.

---

## 4) Create a ClusterIssuer (Let’s Encrypt – Staging)

Always start with **staging** to avoid rate limits.

Create `k8s/clusterissuer-staging.yaml`:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    email: your-email@example.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-staging-key
    solvers:
      - http01:
          ingress:
            class: nginx
```

Apply:

```bash
kubectl apply -f k8s/clusterissuer-staging.yaml
kubectl get clusterissuer
```

Status should be `Ready=True`.

---

## 5) Update your Ingress to use TLS

Edit your existing Ingress (from Day 9).

Create `k8s/day10-ingress-tls.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: app
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - your-domain.example.com
      secretName: web-tls
  rules:
    - host: your-domain.example.com
      http:
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
kubectl apply -f k8s/day10-ingress-tls.yaml
```

---

## 6) Watch certificate issuance (important)

```bash
kubectl -n app get certificate
kubectl -n app describe certificate web-tls
```

Also watch challenges:

```bash
kubectl get challenges -A
```

Expected:

* Certificate transitions to `Ready=True`
* Secret `web-tls` is created

---

## 7) Test HTTPS

Open in browser:

```
https://your-domain.example.com
```

You will see:

* HTTPS works
* Browser warning (because **staging** cert)

This is expected.

---

## 8) Switch to Let’s Encrypt Production (only after staging works)

Create `k8s/clusterissuer-prod.yaml`:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: your-email@example.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
      - http01:
          ingress:
            class: nginx
```

Apply:

```bash
kubectl apply -f k8s/clusterissuer-prod.yaml
```

Update Ingress annotation:

```yaml
cert-manager.io/cluster-issuer: letsencrypt-prod
```

Re-apply Ingress:

```bash
kubectl apply -f k8s/day10-ingress-tls.yaml
```

After issuance, HTTPS will be **fully trusted**.

---

## 9) Common failures & quick fixes

### ❌ Certificate stuck in Pending

* DNS record not pointing to ingress IP
* Wrong ingress class
* Port 80 blocked

Fix:

```bash
kubectl describe challenge -A
```

### ❌ 404 during ACME challenge

* Ingress controller not handling `/.well-known/acme-challenge/`

Fix:

* Ensure `ingressClassName: nginx`
* Ensure no conflicting Ingresses

---

## 10) Security best practices (important)

* Never commit TLS private keys
* cert-manager stores keys in Secrets
* Use **production issuer only after staging works**
* Use separate issuers per environment (dev/stage/prod)

---

## Day 10 completion checklist

1. cert-manager installed and healthy
2. ClusterIssuer (staging) is Ready
3. DNS record points to ingress IP
4. TLS Secret created automatically
5. HTTPS works via Ingress
6. Understood staging vs production

---

## What comes next (final stretch)

You now have:

* AKS
* Persistent storage
* Stateful app
* Ingress
* HTTPS
* CI-controlled Terraform


