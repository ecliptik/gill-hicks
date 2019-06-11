# Terraform

## EKS

The `eks` directory contains terraform configuration for creating an [Amazon Managed EKS Cluster](https://aws.amazon.com/eks/).

This terraform will,

- Create a VPC
- Create public and private subnets withing the VPC
- Create required IAM policies and Security Groups for EKS
  - includespolicy to allow EKS to create [Application Load Balancers](https://aws.amazon.com/elasticloadbalancing/features/#Details_for_Elastic_Load_Balancing_Products) and update [Route53](https://aws.amazon.com/route53/) zones
- Create EKS cluster within public subnet
  - allows access to EKS control plane without a VPN or bastion host
- Create EKS workers within private subnet
  - protects workers by putting them into a private subnet and allows internal communcation with other private AWS services

### Creating EKS Cluster

Update `vars.tf` depending on cluster configuration.

Init and plan, verifying the the EKS cluster is creating the proper resources,

```
terraform init
terraform plan
```

Once plan is verified, create EKS cluster,

```
terraform apply
```

After approximately 15 minutes a new EKS cluster is created.

### Configuring EKS Cluster

Import the EKS configuration into `kubeconfig` using the [aws cli](https://aws.amazon.com/cli/),

First list the EKS clusters to verify it's running and copy the cluster name

```
aws eks list-clusters
```

Update kubeconfig to include EKS cluster configuration,

```
aws eks update-kubeconfig --name $EKS_CLUSTER
```

### Join Worker Nodes

Join the worker nodes to the cluster by generating `config_map_aws_auth` and applying it to the EKS cluster,

```
terraform output config_map_aws_auth > config_map_aws_auth.yaml
```

Apply the configmap,

```
kubectl apply -f ./config_map_aws_auth.yaml
```

Watch node output to verify workers join the cluster,

```
kubectl get nodes -w
```

## MySQL RDS

The hardware service uses a backend MySQL Database to store hardware availibity records.

### Create RDS

Create this MySQL RDS using terraform in the same VPC and with the same Security Group as the EKS workers to allow pods on these workers to communicate privately within the VPC.

First create the EKS cluster using the [EKS terrafrom](/eks) since this builds the required VPCs and subnets.

Init and plan, verifying the the RDS cluster is using the EKS private subnet and worker Security Group. Terraform will prompt to enter the `MYSQL_USER`, `MYSQL_PASSWORD`,  `MYSQL_DATABASE`, and the VPC ID the EKS cluster was created in.

```
terraform init
terraform plan
```

Once verified, apply the configuration to create,

```
terraform apply
```

After creating, output the endpoint, user, and database to update the hardware service configuration with. The password is not included to avoid storing secrets in the repository.

```
terraform output
```

### Import SQL

Since the new RDS is empty, import the database from the [database.sql](../database.sql).

Bring up a temporary mysql pod on the EKS cluster to import data from,

```
kubectl run --generator=run-pod/v1 --image=mysql:5.7 mysql --rm -i --tty -- /bin/bash
```

In a sperate shell, copy the `database.sql` to the temporary msql pod,

```
kubectl cp database.sql mysql:/tmp/
```

Import the sql into the newly created RDS filling in the appropriate configuration to connect based off the terrafrom output and password,

```
mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DATABASE} < /tmp/database.sql
```
