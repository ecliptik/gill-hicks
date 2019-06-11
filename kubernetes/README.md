# Kubernetes

Additional configuration after bring up EKS cluster with terraform.

## ALB Ingress Controller

This deployment uses the [ALB Ingress Controller](https://github.com/kubernetes-sigs/aws-alb-ingress-controller) to create an ALB to allow ingress into a Kubernetes service and automatically update Route53 using the [external-dns](https://github.com/kubernetes-incubator/external-dns) controller.

Install the alb-ingress controller and external-dns before deploying.

```
kubectl apply -f alb-ingress-controller/alb-ingress-controller.yaml
kubectl apply -f alb-ingress-controller/external-dns.yaml
```

## Deploying Portal Application

Update the container image or the version of the application to deploy and the public subnets for what terraform created for the EKS cluster in `manifest.yaml`,

```
kubectl apply -f ./manifest.yaml
```

## Verify Deployment

The deployment will create a Kubernetes service and ingress named `portal`,

```
kubectl get service
kubectl get ingress
```

The ingress controller will create a DNS entry in the configured sub-domain, verify the creation/upsert occured by viewing the `external-dns` pod logs,

```
kubectl logs -f external-dns
```

Use the application by going to it's ingress endpoint domain name.
