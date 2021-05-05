**How to run and Requirment the IAC**

**Requirment**
- There should be a project names as "test-project" in GCP
- "terraform.tfstate" is created in bucket and a bucket should be there with a name as "test-tfstate".
- Not created IAC for bucket because if a user destroy the terraform code, it will also remove the tfstate file which are kept in bucket
- set env variable named as "terraform-sa-json-path" with the SA key.

**How to run:-**
- Go to 3-tier/terraform folder.
- Run "terraform init" to initialize.
- Run "terraform plan -lock=false -out test-plan.out"

**Infrastructure created via IAC:-**
- Webapp with managed instance group(MIG) for high availablity.
- Webapp is atached to a GLB.
- Application server with managed instance group(MIG) for high availablity.
- Application server should have ILB (which is not there due to time constraint), ILB is will be used by webapps to send the traffic.
- Cloud Postgress SQL DB on GCP.

**Architecture of the application:-**

![image](https://user-images.githubusercontent.com/10062294/117170607-cc34e000-ade7-11eb-8568-cd9ebe4932b2.png)

**Info** 
- VPC ICA is there, but its not there in plan as I was not having the right's to provide the requied access to SA to create a VPC, so used the existing VPC.
- Plan for the IAC is attached in the plan folder
