# 🧨 AWS Full Cleanup Script

This script helps you **automatically delete all AWS resources** across all regions to avoid **unwanted charges** after experimenting or practicing with AWS services.

> ⚠️ **Use with caution** — this will delete everything, including EC2 instances, RDS instances, snapshots, Lambda functions, log groups, S3 buckets, and more.

---

## 🛠️ How to Use This Script in AWS CloudShell or Terminal

### 1. Create the script file
```bash

nano aws-full-cleanup.sh

### 2. Make it executable
```bash

chmod +x aws-full-cleanup.sh

### 3. Run it
```bash

./aws-full-cleanup.sh


### tips
```bash

Make sure your AWS CLI is configured properly:
aws configure

You can run this script every time after you're done using AWS to avoid unexpected charges.

This script does NOT delete:

VPCs

IAM Users/Roles

Billing Preferences or Support Plans

📌 Disclaimer
Use this script only if you're absolutely sure that you want to delete all AWS resources. This script is intended for learning or development accounts, not production environments.

💸 Stay Bill-Free!
Run this script regularly after practicing on AWS, and you shouldn't be charged a single rupee 💸


---

Let me know if you want to turn this into a public GitHub repo with a license and some tags — I can help with that too!

💡 Example Script Usage
You can run this script in:

✅ AWS CloudShell (recommended for quick cleanup)

✅ Local Terminal (Linux/macOS) with AWS CLI installed and configured

