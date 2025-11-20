# Terraform AWS EC2 Auto Scaling Infrastructure

### Overview
This project provisions a **highly available AWS EC2 Auto Scaling Group (ASG)** with a **VPC, subnet, Internet Gateway, Route Table, and Security Group** using Terraform.  
It includes a launch template configured with a user data script that installs and starts Apache (`httpd`) on the EC2 instances.

---

### Features
- Create VPC, public subnet, and Internet Gateway
- Configure SSH and HTTP Security Groups
- Create and associate an SSH Key Pair
- Launch EC2 instances via Auto Scaling Group
- Bootstrap instances using user data script
- Modular Terraform design with reusable components

---

### Tech Stack
- **Infrastructure as Code (IaC):** Terraform  
- **Cloud Provider:** AWS (EC2, VPC, IGW, ASG)  
- **Operating System:** Amazon Linux 2  

---

### Setup Instructions

```bash
# Clone the repository
git clone https://github.com/(This Repo).git
cd project

# Configure AWS CLI with your access keys
aws configure

# Generate your SSH key pair and update the path in variables.tf
ssh-keygen -f oregon-region-key-pair

# Initialize Terraform
terraform init

# Validate the configuration
terraform validate

# Review the execution plan
terraform plan

# Apply the infrastructure
terraform apply

# Delete the provisioned infrastructure
terraform destroy
```
