#!/bin/bash
# USER DATA SCRIPT - Executed on EC2 Instance Launch
# This script automatically installs and configures Apache Web Server

set -e  # Exit on error

# Update system packages
yum update -y

# Install Apache HTTP Server
yum install -y httpd

# Create a simple health check page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to Terraform ASG Infrastructure</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            max-width: 600px;
        }
        h1 { color: #FF9900; }
        .info { 
            background-color: #f0f0f0;
            padding: 10px;
            margin: 10px 0;
            border-left: 4px solid #FF9900;
        }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1> Terraform AWS EC2 Auto Scaling Infrastructure</h1>
        
        <div class="info">
            <p><strong>Instance Status:</strong> <span class="status">✓ Running</span></p>
            <p><strong>Web Server:</strong> Apache HTTP Server (httpd)</p>
            <p><strong>Region:</strong> us-west-2</p>
            <p><strong>Environment:</strong> Development</p>
        </div>

        <h2> Infrastructure Details</h2>
        <div class="info">
            <p>This instance is part of an Auto Scaling Group that:</p>
            <ul>
                <li>Scales from 1 to 3 instances based on CPU load</li>
                <li>Automatically replaces failed instances</li>
                <li>Distributes traffic across multiple availability zones</li>
                <li>Monitors CPU utilization with CloudWatch alarms</li>
            </ul>
        </div>

        <h2> Security Features</h2>
        <div class="info">
            <ul>
                <li>VPC isolation with custom CIDR blocks</li>
                <li>Security groups with granular access control</li>
                <li>SSH key-based authentication</li>
                <li>HTTP and HTTPS traffic support</li>
            </ul>
        </div>

        <h2>✨ Next Steps</h2>
        <div class="info">
            <p>To enhance this infrastructure:</p>
            <ul>
                <li>Configure an Application Load Balancer (ALB)</li>
                <li>Add database backend (RDS)</li>
                <li>Implement custom application deployment</li>
                <li>Set up CloudFront CDN</li>
                <li>Enable logging and monitoring</li>
            </ul>
        </div>

        <hr>
        <p style="text-align: center; color: #666; font-size: 12px;">
            Instance ID: <code>i-xxxxxxxxx</code><br>
            Deployment Time: <span id="time"></span>
        </p>
    </div>

    <script>
        document.getElementById('time').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Create a health check endpoint for ALB (optional)
cat > /var/www/html/health.html << 'EOF'
{
  "status": "healthy",
  "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "service": "terraform-asg-infrastructure"
}
EOF

# Create a metrics endpoint for monitoring (optional)
cat > /var/www/html/metrics.txt << 'EOF'
# Instance Health Metrics
instance_status=healthy
web_server=running
response_time_ms=0
cpu_utilization_percent=0
memory_available_percent=100
EOF

# Enable Apache to start on boot
systemctl enable httpd

# Start Apache HTTP Server
systemctl start httpd

# Configure log rotation for Apache logs
cat > /etc/logrotate.d/httpd << 'EOF'
/var/log/httpd/*log {
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        /bin/kill -SIGUSR1 `cat /var/run/httpd.pid 2>/dev/null` 2>/dev/null || true
    endscript
}
EOF

# Add CloudWatch monitoring scripts (optional)
yum install -y amazon-cloudwatch-agent

# Create a simple monitoring script
cat > /usr/local/bin/health-check.sh << 'EOF'
#!/bin/bash
# Health check script - can be called by monitoring systems

if systemctl is-active --quiet httpd; then
    exit 0
else
    exit 1
fi
EOF

chmod +x /usr/local/bin/health-check.sh

# Log script execution
echo " User data script completed successfully at $(date)" >> /var/log/user-data.log
echo " Apache HTTP Server installed and started" >> /var/log/user-data.log
echo " Health check endpoints configured" >> /var/log/user-data.log
```

---

## FILE 5: .gitignore
```
# Terraform Files - Never commit these to version control

# Terraform state files (contain sensitive data and local machine configs)
*.tfstate
*.tfstate.*
.terraform.lock.hcl

# Terraform directories
.terraform/
.terraform.d/

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files which might contain sensitive data
*.tfvars
*.tfvars.json
!example.tfvars

# Ignore override files - these are usually used for local overrides
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc


# IDE & Editor Files

# VS Code
.vscode/
*.code-workspace

# JetBrains IDEs
.idea/
*.iml
*.iws
*.ipr

# Sublime Text
*.sublime-project
*.sublime-workspace

# Vim
*.swp
*.swo
*~
.vim/

# Nano
.nanorc


# OS Files

# macOS
.DS_Store
.AppleDouble
.LSOverride
._*
.Spotlight-V100
.Trashes

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# Linux
.directory


# SSH Keys & Secrets (CRITICAL - Never commit private keys)

# SSH keys
*.pem
*.key
*.pub
.ssh/
private_key/
public_key/
oregon-region-key-pair*

# Sensitive files
secrets.txt
.env
.env.local
credentials.json
aws_credentials


# Log Files
*.log
logs/
*.out


# Temporary Files
*.tmp
*.bak
*.backup
*.swp
temp/
tmp/


# Build Artifacts
dist/
build/
*.tar.gz
*.zip


# Plan Files (Optional - exclude to avoid accidental applies)
tfplan
*.tfplan
plan.out

# Documentation Build Files
docs/_build/
site/