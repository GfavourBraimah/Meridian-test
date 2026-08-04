# Meridian Retail - Enterprise Cloud Infrastructure & DevSecOps Pipeline 

**Lead Cloud & DevSecOps Engineer:** God'sfavour Braimah

##  Executive Summary
This document outlines the architecture, deployment, and security strategies implemented for the **Meridian Retail** microservices ecosystem. The objective of this deployment was to engineer a highly available, secure, and fully automated cloud infrastructure that bridges the gap between rapid software delivery and robust enterprise security. 

By utilizing an "Infrastructure as Code" (IaC) methodology alongside advanced DevSecOps pipelines, this environment ensures zero-downtime deployments, strict identity management, and automated disaster recovery capabilities.

---

##  1. Enterprise Architecture & Infrastructure as Code (IaC)
The foundation of the Meridian Retail platform is built on a custom, hardened AWS networking environment designed for scale and security.

*   **Virtual Private Cloud (VPC) & Subnetting:** The infrastructure is isolated within a custom VPC, utilizing properly configured Route Tables and an Internet Gateway (IGW) to manage ingress and egress traffic safely.
*   **Infrastructure as Code (Terraform):** The entire AWS environment (EC2 instances, Security Groups, VPC configurations) was provisioned using Terraform. 
*   **Remote State Management:** To ensure team collaboration and prevent state corruption, the Terraform configuration utilizes an **Amazon S3 backend** for encrypted state storage, coupled with a **DynamoDB table** for state locking.

  **D1**  All four containers running![ D1](/images/D1.png)

  **ECR** ![ECR](/images/D1a.png)

 **EC2** ![EC2](/images/D1b.png)

---

##  2. DevSecOps & CI/CD Pipeline (GitHub Actions)
A two-stage CI/CD pipeline was engineered to separate the build process from the deployment process, enforcing a strict "Shift-Left" security posture.

### Vulnerability & Secret Scanning
Before any code is deployed, the pipeline runs critical security checks:
*   **Gitleaks (Secret Scanning):** Scans the repository for hardcoded credentials or API keys, generating a standard JSON report.
*   **Trivy (Filesystem Scanning):** Analyzes the application dependencies and Dockerfiles for CVEs, generating a comprehensive HTML report. 
*   **Non-Blocking Execution:** Both tools are integrated with `continue-on-error: true` and artifact uploads. This ensures security teams receive immediate vulnerability reports via the GitHub UI without halting emergency hotfixes or active deployments.

### Dynamic AWS Security Group IP Whitelisting
To adhere to Zero-Trust networking principles, the AWS EC2 instance strictly denies SSH (Port 22) access by default. 
*   During the deployment job, the pipeline dynamically resolves the specific GitHub Runner's IP address.
*   It utilizes the AWS CLI to whitelist this exact IP in the EC2 Security Group *just-in-time*.
*   Files are securely transferred via SCP, the Docker stack is updated via SSH, and the automated scripts are executed. 

> [![ GitHub Actions workflow run](/images/D8c.png)- Shows the successful GitHub Actions workflow run, specifically highlighting the Trivy/Gitleaks steps, the uploaded security artifacts, and the IP whitelisting step.]

---

## 3. Identity & Access Management (IAM) & Security
Security is baked into the IAM layer to prevent credential leakage and enforce the Principle of Least Privilege:
*   **IAM Roles & Policies:** Specific AWS IAM policies were crafted to allow GitHub Actions to securely authenticate and push Docker images to the Amazon Elastic Container Registry (ECR).
*   **Secure Authentication:** The pipeline uses short-lived, securely scoped credentials (`aws ecr get-login-password`) to authenticate the Docker CLI without storing permanent AWS root keys on the servers.

---

##  4. Traffic Routing, Nginx & SSL (Certbot)
To expose the internal Docker microservices securely to the internet, a production-grade Nginx reverse proxy was configured.

*   **Domain Resolution:** Configured dynamic DNS resolution using DuckDNS (`shop-meridian.duckdns.org`).
*   **SSL/TLS Cryptography:** Integrated Let's Encrypt via **Certbot** to automatically provision and bind SSL certificates to the Nginx server, enforcing strict HTTP-to-HTTPS (301) redirects for data-in-transit encryption.


**D4**  ![ GitHub Actions workflow run](/images/D4.png)
  **D5**  ![ GitHub Actions workflow run](/images/D5.png)
 **D6** ![ GitHub Actions workflow run](/images/D6.png)

### Solving the API Routing & Trailing Slash Issue
During deployment, the FastAPI `orders-service` triggered `307 Temporary Redirect` errors resulting in cross-origin "Failed to fetch" blockages on POST requests. This was resolved by meticulously configuring Nginx to proxy the requests without trailing slashes.

**Nginx Configuration Snippet:**
```nginx
# Route Orders Service API requests (Trailing slash fix implemented)
location /api/orders {
    proxy_pass [http://127.0.0.1:8003](http://127.0.0.1:8003);
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

```

##  5. Container Orchestration & Disaster Recovery
The Meridian Retail application ecosystem is fully containerized and orchestrated using Docker Compose.

- **Microservices Architecture:** The stack includes a Node.js/React frontend on port 8080, an Auth Service on port 8001, a Catalog Service on port 8002, an Orders Service on port 8003, and a PostgreSQL database on port 5432.
- **Automated Database Seeding:** Startup race conditions and credential mismatches were resolved by configuring the correct PostgreSQL role and permissions for the Meridian user. The catalog service now successfully auto-seeds authentic product data during boot.

  **D2** - Showing the PostgreSQL terminal output running `SELECT * FROM products;` confirming the 5 seed items exist.  ![ GitHub Actions workflow run](/images/D2.png)

 **D3** - Showing the frontend UI fully loaded in the browser. ![ D3](/images/D3.png)

   **Dig DNS** ![ Dig DNS](/images/D3b.png)

 **D7** - Show the end-to-end flow: the UI displaying products, a successful login, and an order successfully placed.![ D7](/images/D7.png)

### Business Continuity & Disaster Recovery
To ensure resilience against accidental deletion or corruption, automated backup and recovery scripts were engineered for the database layer:

- `backup_db.sh`: Creates compressed SQL dumps (`.sql.gz`) with timestamped filenames for point-in-time recovery.
- `restore_db.sh`: Rapidly drops and restores the database from the compressed archive. The recovery procedure was successfully tested and verified in the live environment.

**D9** - Showing the terminal output of the `restore_db.sh` script successfully completing and restoring the database. ![ D9](/images/D9.png)
>
> [ **INSERT SCREENSHOT HERE: D10** - Insert a screenshot of this completed README or your GitHub repository structure, proving all deliverables are compiled and documented.]

meridian-retail/
├── .github/
│   └── workflows/
│       ├── ci-build-push.yml    # Builds the 4 images, scans with Trivy/Gitleaks, pushes to ECR
│       └── cd-deploy-ec2.yml    # Whitelists IP, SCPs files, SSHes into EC2, and redeploys
├── docker-compose.yml           # Orchestrates Frontend, Auth, Catalog, Orders, and PostgreSQL
├── nginx/
│   └── meridian-http.conf       # Reverse proxy, API routing, and SSL configuration
├── scripts/
│   ├── backup_db.sh             # Disaster recovery database dump script
│   └── restore_db.sh            # Disaster recovery database restore script
└── README.md                    # The Masterclass Deployment Report

*Architecture and deployment executed by God'sfavour Braimah for Meridian Retail. Engineered for resilience. Built for scale.*