<img align='right' src=".github/cover.png" style='width: 100%; margin-bottom: 20px; border-radius: 4px'>

<div align='center'>
<h1>Deploy React app in AWS ECS with Terraform</h1>
</div>

---

### Backend
In this lab we will store the terraform.state in an AWS S3. 
As it is not allowed to use variables in a backend block, we can define the configuration values in a `.conf` file, as follows:

```
# file.conf 

region="us-east-1"
profile="aws credencials "
bucket="bucket name"
``` 
With the configuration file defined, we can start terraform:
```
terraform init -backend-config=file.conf
```