# Gill Hicks

Flask application to display hardware availability.

This application has two services,

- `hardware` - Query a database for hardware availability and server on route `/hardware`
  - listens on port 5001
- `portal` - Frontend to query hardware service and display results
  - listens on port 5000

## Code Changes

The following changes were done in order to the app to satisfy requirements,

- Updated `database.sql` to use `AUTO_INCREMENT` mysql syntax for primary key index
- Used environment variables instead of hardcoded configuration for environment agnostic configuration
- Added [flask-mysql](https://flask-mysql.readthedocs.io/en/latest/) to connect to MySQL database

## Prerequisites

Before deploying the application, [terraform](https://www.terraform.io/) is used t bring up the AWS EKS Kubernetes Cluster and AWS MySQL RDS. Kubernetes is used as the container orchestration engine to provide cloud native integration with AWS servies such as Route53 and ALB to run the application, and RDS for stateful storage.

See [terraform/README.md](terraform/README.md) for creating the required AWS resources with terraform.

See [kubernetes/README.md](kubernetes/README.md) for preparing the Kubernetes cluster for deployments.

## Configuration

Configured using Environment Variables

- MYSQL_HOST - Hostname of MySQL Database to use
- MYSQL_USER - MySQL database user name to connect with
- MYSQL_PASSWORD - MySQL password to connect with
- MYSQL_DATABASE - MySQL database to use
- HARDWARE_HOST - Hostname where hardware appliation runs

## Kubernetes Deployments

The `Makefile` in this repository contains macros for common build and deploy tasks,

- build - builds container - sets the docker tag to the BRANCH-SHA for versioning
- push - pushes container to Dockerhub
- secret - takes environment variables and generates a kubernetes secret to apply to the cluster
- deploy - runs all of the above
  - updates the Kubernetes deployment in `./kubernetes/manifest.yaml` to the latest docker tag from the build step
  - updates secrets based on environment variables - ideally these would be set in a CI/CD system and not manually everytime
  - deploys application with `kubectl apply -f ./kubernetes/manifest.yaml`

The Makefile will automatically update the DOCKER_TAG based off the branch/sha and deploy this version. This should be done within a proper CI/CD system such as Jenkins to leverage deployment history, access control, automated deployments, unit tests, and rollbacks by selecting available tags on an image instead of manually modyfing it within the repository everytime.

This application uses a Kubernetes secret for sensitive database information. The `secret` macro will generate this, using the defaults in `Makefile`. For production use, such as pointing to an RDS instance, these values should be set in the shells environment in order not leak secrets into the file itself. These values are output when `./terraform/rds/output.tf` is run after using terraform to create the RDS intance.

Example commands to set secrets and deploy,

```
export MYSQL_HOST=hardware-db.c4plnugcdpjl.us-east-1.rds.amazonaws.com
export MYSQL_USER=hardware
export MYSQL_PASS=rds-password-set-in-terraform
export MYSQL_DATABASE=hardware

make deploy
```

## Local Deployment

Deploy locally using [docker-compose](https://docs.docker.com/compose/) for testing without using AWS resources.

```
docker-compose up
```

Connect to http://locahost:5000

### Local Deployment Configuration

Update `docker-compose.yaml` to change configuration values in the `environment` blocks.

## Makefile

This repository has a `Makefile` that scripts many of the tasks for this application.


Build docker image locally

```
make build
```

Generate Kubernetes Secret in `.secret`

```
make create_secert
```

Deploy application - builds, tags, pushes, updates config, and deploys to k8s

The following environment variables should be set to the production values in order to deploy to kubernetes. After creating the RDS with terraform, running `terraform output` will diplays all of these except the MYSQL_PASSWORD which should be stored somewhere secure

- MYSQL_HOST - RDS endpoint
- MYSQL_USER - Database user
- MYSQL_PASSWORD - Database user password
- MYSQL_DATABASE - Hardware database name

```
make deploy
```

## Future Improvements
### Caching

To improve reponse time around from calculating hardware availability that is CPU bound (extra credit #2), add a caching layer with a reasonable timeout. This will allow subsequent calls for the same queries to return faster and periodically refresh data when changed.

The [https://pythonhosted.org/Flask-Cache/](Flask-Cache) library is a good example.

### WGSGI Server

The applications currently run using flasks built-in webserver, which does not scale well and is limited in capabilities. Using [gunicorn](https://gunicorn.org/) and setting it up to use a worker like [eventlet](http://eventlet.net/) or [gevent](http://www.gevent.org/) will allow the app to handle multiple processes and server a larger amount of requests and not block while processing.

### Cost Optimization

Because the application uses a backend database and does not store any state locally, it can run entirely ephermally which makes it an ideal application for Spot Instances to lowere overall Kubernetes cluster costs. AWS Austoscaling groups provide an option to use Spot Pricing, but using a managed product like [SpotInst](https://spotinst.com/) makes running a Kubernetes cluster on spot instances easier with less operational overhead.

### Scaling

Using [Horizontal Pod Sclaer](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) and [Prometheus](https://prometheus.io/) with custom httpmetrics, pods can scale up and down depending on the incoming traffic. See this [example](https://docs.bitnami.com/kubernetes/how-to/configure-autoscaling-custom-metrics/) for a possible way this is setup.

Furthermore, if using [SpotInst Ocean](https://spotinst.com/products/ocean/) or [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler), node scaling can occur automatically based on metrics and increase resources for additional pods.

Using HPA and a Cluster Autoscaler together allows for dyanmic scaling of the service and the underlying infrastructure in response to increasing and decreasing load.
