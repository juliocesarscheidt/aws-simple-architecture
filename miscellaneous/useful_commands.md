# Useful Commands

## cloud-init commands

```bash
cloud-init status --wait > /dev/null

/etc/init.d/cloud-init-user-scripts

cat /var/log/cloud-init.log
cat /var/log/cloud-init-output.log
```

## EC2 info files

```bash
cat /etc/image-id
cat /etc/system-release
cat /etc/os-release
```

## EC2 spot fleet role creation / EC2 describing images

```bash
aws iam create-role --role-name AmazonEC2SpotFleetRole \
  --assume-role-policy-document \
  '{"Version":"2012-10-17","Statement":[{"Sid":"","Effect":"Allow","Principal":{"Service":"spotfleet.amazonaws.com"},"Action":"sts:AssumeRole"}]}'

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole \
  --role-name AmazonEC2SpotFleetRole

aws ec2 describe-images --owners self amazon \
  --filters \
  "Name=name,Values=amzn2-ami-hvm-2.0.*" \
  "Name=architecture,Values=x86_64" \
  "Name=virtualization-type,Values=hvm"
```

## EC2 IP info

```bash
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
```

## Terraform commands

```bash
terraform fmt -write=true -recursive

terraform init

terraform validate

terraform plan -detailed-exitcode -input=false
terraform plan -detailed-exitcode -input=false -target=resource

terraform refresh

terraform show

terraform output

terraform apply -auto-approve
terraform apply -auto-approve -target=resource

terraform destroy -auto-approve
```
