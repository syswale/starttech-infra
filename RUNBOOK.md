# Infrastructure Operational Runbook

## 1. Modifying Infrastructure State
All infrastructure changes must be executed via Terraform. Manual changes in the AWS Console are strictly prohibited as they will cause state drift.

**Resolution for State Drift:**
If manual changes are detected, run a refresh and plan to see the discrepancies, then apply the code to force the AWS environment back to the defined state.
```bash
terraform refresh
terraform plan
terraform apply
```
## 2. Scaling the Backend
If the application experiences sustained high traffic, the ASG limits may need to be adjusted.

Open the ```variables.tf``` file.

Locate the ```asg_max_size``` and ```asg_desired_capacity``` variables.

Increase the integer values appropriately.

Run ```terraform plan``` and ```terraform apply``` to deploy the scaling changes.
