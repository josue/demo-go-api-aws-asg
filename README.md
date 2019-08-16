## Golang REST API with an automated AWS auto-scaled deployment

A deployable Go API with an automated setup process for an AWS Auto-Scaling Group (high-availability and performance), via an ELB endpoint.

_The entire build (and destroy) process runs inside a docker container, initiated via Makefile targets._

----

## 📦 Requirements:

1. [AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
2. [Docker for Mac/Windows/Linux](https://docs.docker.com/docker-for-mac/install/)

#### (optional) Note:

If you'd like to run the internal build scripts on your native OS environment (without Docker), it requires you have installed:

- Python 3.7+
- aws-cli 1.16+
- Git 2.1+
- Golang 1.10+
- Packer 1.4.2+
- Terraform 1.12+
- jq 1.6+
- wrk 4.1.0+

Homebrew: `brew install python awscli git go packer terraform jq wrk`

- _With Docker: All steps have been tested using Docker Desktop v2.1_
- _Without Docker: All internal scripts have been tested on MacOS v10.14 - Mojave_

----

## 🔑 Configure your AWS Access/Secret Keys:

Obtain your private AWS credentials, then either setup `aws configure` or export the environment variables.
```bash
export AWS_ACCESS_KEY_ID=.....
export AWS_SECRET_ACCESS_KEY=....
```
_Ensure your credentials has IAM `"AdministratorAccess"` permissions._

(optional) You may specify your desired AWS region _(us-east-1, eu-west-2, etc)_ via env var:
```bash
export AWS_REGION=us-east-1
```
_Default region: **us-east-1**_

----

## 👷 Setup App + Infras ➠ 💾 Compile ➜ ⚙ Build ➜ 🏭 Deploy ➜ ⚡ Load Test

Run the Makefile target:
```bash
make docker_build_deploy_all
```

This will start the following sequence:

1. Build a docker container with tag and run it: _"api_build_deploy"_

2. Inside the Docker container, it will perform the following actions:
    1. Init local files, ssh keys, etc
    2. Run test and compile the [Golang API](api/) binary
    3. Build an AWS AMI (image) using Packer
    4. Build an AWS Auto-Scaling Group (ASG) to deploy and manage the AMI image using Terraform
    5. Run health check & automated load test on the ELB API endpoint for 30 seconds


⭐ Recommended to run the above Makefile target using the predefined Dockerfile.

However, you can run the above build process without Docker with the Makefile target: `make external_build_deploy_all`

#### Deployment & Other Notes

- AMI image info:
    - Instance Type: `t2.micro`
    - OS: `Debian`
    - Tags: `Name:API - {date}, Release:api-latest`

- Auto-Scaling Group (ASG) will start with one instance, with up to five instances capacity.

- CloudWatch alarms are created to notify ASG when any EC2 "CPU utilization" average is:
    1. High - above the **60%** CPU threshold, which increases ASG capacity by one instance at a time.
    2. Low - below the **10%** CPU threshold, which decreases ASG capacity by one instance at a time.

_The above (and more) can be configurable via the variables files:_
- Packer: `infras/packer/variables.json`
- Terraform: `infras/terraform/variables.json`

----

## 🧹 Destroy ➜ Cleanup

Run the Makefile target:
```bash
make docker_destroy_all
```

Cleanup script will perform the following sequence:

1. Terraform will destroy this specific AWS (API) deployment configuration _(based on existing 'terraform.tfstate' file)_
2. Deregisters all related API images via tag `"Release:api-latest"`
3. Deletes all related Snapshots via tag `"Release:api-latest"`

⭐ Recommended to run the above Makefile target using the predefined Dockerfile.

However, you can run the above destroy process without Docker with the Makefile target: `make external_destroy_all`

----

## 💁 Miscellaneous Notes

- Docker run is configured to mount this project directory as a volume.
- Generated files _(ie: terraform.tfstate, ssh keys, etc)_ on build time should be available in the current directory, should you need it for backup purposes.


🤓 _For questions or comments, please create an Issue or [contact me](mailto:code@josue.io?subject=Github:Golang-API-AWS-Deploy) anytime._

**Enjoy!**

----

## 🎞 Demo Time

[![asciicast](https://asciinema.org/a/dMRCIQtBGs8R4Xk5FXdMMfJTH.svg)](https://asciinema.org/a/dMRCIQtBGs8R4Xk5FXdMMfJTH)
