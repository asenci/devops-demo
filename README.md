# DevOps Demo

## Deploying with Terraform

### Dependencies

#### Docker Desktop

Download and install Docker Desktop from: https://www.docker.com/products/docker-desktop/

On Windows use the WSL 2 backend.

#### AWS IAM credentials

Create a set of IAM credentials with the `AdministratorAccess` policy attached.

Create a `.env.local` file inside the `terraform` directory with the AWS credentials as environment variables.

This can be achieved by running:

```shell
cat >>terraform/.env.local <<EOF
AWS_ACCESS_KEY_ID='<your access key>'
AWS_SECRET_ACCESS_KEY='<your secret key>'
EOF
```

### Deploying

To deploy the application:

```shell
docker compose run --rm terraform init
docker compose run --rm terraform apply -auto-approve
```

After completing the deployment process, Terraform will output the deployment URL. E.g:

```terraform
Apply complete! Resources : 45 added, 0 changed, 0 destroyed.

Outputs:

deploy-url = "http://xxxxxxxxxxxx.elb.amazonaws.com"
```

If you get an error regarding the `.env.local` file or the AWS provider configuration, please review the
[AWS IAM credentials](#aws-iam-credentials) section and make sure the contents of your `.env.local` file match your credentials.
E.g.
```
$ cat terraform/.env.local
AWS_ACCESS_KEY_ID='XXXXXXXXXXXXXXXXX'
AWS_SECRET_ACCESS_KEY='YYYYYYYYYYYYYYYYY'
```

### Updating

To deploy a new version of the application, run `terraform apply` again:

```shell
docker compose run --rm terraform apply -auto-approve
```

After completing the update proccess, Terraform should output the number of resources modified:
```terraform
Apply complete! Resources: 2 added, 1 changed, 2 destroyed.
```

### Cleaning up

To destroy all resources created by the application:

```shell
docker compose run --rm terraform destroy
```

Please review all changes carefully as **this operation can not be reverted**.

To accept the changes, type `yes` and press ENTER.

## Local development with Docker

### Dependencies

#### Docker Desktop

Download and install Docker Desktop from: https://www.docker.com/products/docker-desktop/

On Windows use the WSL 2 backend.

### Starting

To start the development environment (press CTRL+C to stop):

```shell
docker compose up
```

The following endpoints are available:

- http://localhost/ (Main website)

### Monitoring

To monitor the containers status and logs, use the Docker Desktop dashboard or the following commands:

- To list the status of the containers:

```shell
docker compose ps
```

- To monitor the logs (press CTRL+C to stop):

```shell
docker compose logs --tail=0 --follow
```

### Stopping

To stop the development environment:

```shell
docker compose down
```

### Cleaning up

To clean up the Docker Compose resources:

```shell
docker compose down --volumes --remove-orphans
```
