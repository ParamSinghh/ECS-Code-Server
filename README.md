# ECS Code Server Deployment

A production-grade deployment of [code-server](https://github.com/coder/code-server) (VS Code in the browser) on AWS ECS Fargate, with full infrastructure as code and CI/CD automation.

## 🌐 Live URL
https://tm.paramsingh.co.uk

## 🏗️ Architecture

```
Internet
    ↓
Route 53 (tm.paramsingh.co.uk)
    ↓
ALB (HTTPS:443 / HTTP:80 → redirect)
    ↓
ECS Fargate (code-server container)
    ↓
ECR (Docker image storage)
```

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| Docker | Containerisation |
| AWS ECS Fargate | Container orchestration |
| AWS ECR | Container image registry |
| AWS ALB | Load balancing |
| AWS VPC | Networking |
| AWS ACM | HTTPS certificate |
| AWS Route 53 | DNS management |
| Terraform | Infrastructure as code |
| GitHub Actions | CI/CD pipeline |

## 📁 Project Structure

```
├── app/                    
├── Dockerfile              
├── .dockerignore           
├── infra/                  
│   ├── main.tf             
│   ├── variables.tf        
│   ├── outputs.tf          
│   ├── provider.tf         
│   └── modules/
│       ├── vpc/            
│       ├── ecs/            
│       ├── alb/            
│       ├── ecr/            
│       └── acm/            
├── .github/
│   └── workflows/
│       ├── docker.yml      
│       └── terraform.yml   
└── README.md
```

## 🚀 Deployment

### Prerequisites
- AWS CLI configured
- Terraform installed
- Docker installed

### Deploy Infrastructure
```bash
cd infra
terraform init
terraform apply -var-file="terraform.tfvars"
```

### Destroy Infrastructure
```bash
cd infra
terraform destroy -var-file="terraform.tfvars"
```

## ⚙️ CI/CD Pipeline

Two automated pipelines run on push to main:

**Pipeline 1 — Docker**
- Builds Docker image
- Tags with commit SHA and latest
- Pushes to ECR

**Pipeline 2 — Terraform**
- Runs terraform init, fmt, validate, plan and apply
- Post deploy health check at https://tm.paramsingh.co.uk

## 🔒 Security
- OIDC authentication — no static AWS keys stored in GitHub
- Non-root user inside Docker container
- ECS tasks only accept traffic from ALB security group
- HTTPS enforced with automatic HTTP → HTTPS redirect
- ACM certificate for TLS termination at ALB

## 👤 Author
Param Singh — [GitHub](https://github.com/ParamSinghh)