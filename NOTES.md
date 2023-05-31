# Notes on the tech-stack

## Code

The Source code for the application is stored in a public GitHub repository, but there are no dependencies on the GitHub
ecosystem other than the simple CI test workflow and Dependabot for convenience.

A Docker Compose file is provided for easy setup of a local test environment and execution of development tools such
as Terraform. In the future this could also be leveraged to provide easy access to other tools such as `kubectl` to the
developers.

## Test

A simple Docker build workflow ensures the Docker image can be built from a clean repository.

Ideally the CI tests should be started by a task runner such as Earthly (or even a simple Makefile) to make the CI
pipeline more platform-agnostic, and allow the developers to run the tests locally for faster feedback.

More broad testing is highly desirable, starting with code linters which are easy to implement.

Running a Terraform `plan` on pull requests is also desirable, but would require a centralised Terraform state (either
stored on Terraform Cloud or a remote backend such as S3), and was avoided to keep the setup process as simple as
possible. This would allow PR reviewers to quickly evaluate the impact of changes in the Terraform scripts.

Given enough time, integration tests could also have been implemented in the CI pipeline, making sure both the local
development environment and the deployed application is working properly. Such tests can be as simple as sending
requests to the application and checking the response for specific patterns (I.e. `curl | grep`), or as advanced as
automated browser testing using tools such as Selenium. They can also provide valuable insight into the performance of
the application and application-specific metrics such as Core Web Vitals.

## Build

The application is packaged as a Docker container image due to its wide support.
Once built, the image can be deployed either directly to Docker or using an orchestrator such as Kubernetes, Amazon
ECS, or Hashicorp Nomad.

Another option would have been packaging the application as a complete OS image (either as an AMI, or as a KVM disk
image). The build process can be automated using tools such as Hashicorp Packer, but the resulting images are not as
versatile as Docker images and require more resources to run, which can impact the developer experience.

At the moment, the application image is built as part of the Terraform deployment process to simplify the setup
requirements, but ideally it should run as a separate process in the CI/CD pipeline for better control of the build

Building images for both ARM and X86 platforms would also be desirable due to the proliferation of ARM-based platforms
in developer workstations, and the potential cost savings in compute resources.

## Release

The release process is controlled by Terraform and consists in checking for changes in the application source directory,
and building a new container image if required.

If a new container image is built, it also gets pushed to the ECR registry for retrieval from the Kubernetes cluster.
For simplicity, only one version of the container image is stored in the ECR registry (labeled as `latest`)

Similar to the build process, a better approach would be to move the release process to the CI/CD pipeline so a new
image build can be triggered when a change is committed to the code repository. This would also allow for proper
versioning of the images and upload to separate container registries for development and deployment purposes (e.g. GHCR
for developers, and ECR for deployment).

## Deployment

The deployment process is also controlled by Terraform and consists roughly in the following steps:

- Provisioning of the EKS Kubernetes cluster and dependencies
- Provisioning of the ECR container registry
- Building the application container image, and pushing it to ECR
- Creating a Kubernetes deployment for the application
- Creating a Kubernetes service for exposing the application entrypoint via an ELB

At the end of the deployment process, Terraform outputs the ELB URL which can be used by the developer for testing or
for publishing.

To simplify the setup process, TLS support was considered out of scope and should be implemented as an additional layer
in front of the load balancer. In a production environment, the application would ideally be exposed via an ingress
controller such as NGINX or Traefik, which would handle the TLS provisioning.

The network segmentation, and access control were also kept to a minimal to simplify the resulting Terraform code, but
could be better implemented in a production environment by deploying dedicated VPCs, tightening up the security group
rules, and implementing a cloud-native network security tool such as Cilium or Calico.

The Terraform code is mostly contained in the `terraform/main.tf` file to simplify reading and comprehension of the
code, but a better approach would be to have the Terraform code split into modules for better maintainability and
reliability across projects, ideally residing in a separate repository so the infrastructure provisioning is properly
segregated from the application development process.

Another benefit of splitting the infrastructure provisioning code is that the IAM permissions can be tightened up,
following the principle of least privilege.

As for the application deployment process, it would be better handled by a CD tool more suited for GitOps such as Argo
CD or Drone, specially if used with Helm for better handling of staging environments.

## Operations

In a production environment, more generous limits could be applied to the application replicas, and EKS node group
settings to allow for spikes in traffic. Tools such as Horizontal Pod Autoscaler can also be used to optimise the
resource usage.

Further documentation of the Kubernetes environment operations and troubleshooting would be highly beneficial for all
parts involved in the development and operation processes.

EC2 bastion nodes could also be deployed for secure access to the cluster resources and help with troubleshooting.

## Monitoring

At the moment, only basic network-level health-checks are being performed by the load balancer, but ideally each
application should have proper health-checks defined in the deployment configuration so the Kubernetes cluster can
properly identify a faulty deployment.

Detailed monitoring of the infrastructure resources and the application can the achieved by implementing a monitoring
solution such as a Prometheus/Grafana/Loki stack, or by using commercial solutions such as DataDog or New Relic.  
