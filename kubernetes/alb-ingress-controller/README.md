# ALB Ingress Controller

Upstream docs:
- https://github.com/kubernetes-sigs/aws-alb-ingress-controller
  - AWS example: https://github.com/kubernetes-sigs/aws-alb-ingress-controller/tree/master/docs/examples
- https://github.com/kubernetes-incubator/external-dns
  - https://github.com/kubernetes-incubator/external-dns/blob/master/docs/tutorials/aws.md

# Deploying
## IAM Policy
Create a new IAM policy called alb-ingress and use the `iam-policy.json` in this repo (this is already done if created with SpotInst EKS terraform). This policy will allow access to

- ALB/ELB
- WAF
- Route 53

Apply the policy to the EKS node role in order for the EKS nodes to use it and have access to ALB/ELB/WAF/Route53.

If the policy isn't set properly the alb-ingress-controller and external-dns pods will give an errors about lacking permissions.


## aws-alb-ingress-controller

Update `alb-ingress-controller.yaml` to match your cluster name `--cluster-name=your-cluster-name.yourdomain.com`

Switch to the `kube-system` namespace and apply the `alb-ingress-controller.yaml`,

```
kubectl apply -f alb-ingress-controller.yaml
```

Make sure the the `alb-ingress-controller.yaml` has ` - --watch-namespace=your-k8s-namespace` commented out in order to read services in all namespaces.

## external-dns

In `external-dns.yaml`, update `--domain-filter=` to the domain of the route53 zone the pod will modify (ie app-dev.demandbase.com).
In `external-dns.yaml`, update `--txt-owner-id=my-identifier` to the cluster name (ie gdpr-dev-us-east-1)

Switch to the `default` namespace (it cannot run in kube-system otherwise it will give an error of `services is forbidden: User \"system:serviceaccount:kube-system:external-dns\" cannot list services at the cluster scope"` - see https://github.com/kubernetes-incubator/external-dns/issues/754).

Apply the `external-dns.yaml`

```
kubectl apply -f ./external-dns.yaml
```

## Setting up Ingress to Application

For full docs see: https://kubernetes-sigs.github.io/aws-alb-ingress-controller/
