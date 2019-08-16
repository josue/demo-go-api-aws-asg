#!/bin/bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

ctrl_c () {
    echo "** Trapped CTRL-C"
}

CURR_DIR=`pwd`
PARKER_DIR="${CURR_DIR}/infras/packer"
TERRAFORM_DIR="${CURR_DIR}/infras/terraform"
SSH_KEY_FILE="${CURR_DIR}/ssh_keys/aws_api"

D="\u254D"
D2="${D}${D}"
D4="${D2}${D2}"
D_PRE="${D4}${D2}"

if [ "${INSIDE_DOCKER}" = "1" ]; then
    source ~/.profile
fi

title () {
    python -c "print(u\"\\${1}\".encode('utf-8').strip())"
}

check_aws_credentials () {
    if [ "${AWS_ACCESS_KEY_ID}" = "" ] || [ "${AWS_SECRET_ACCESS_KEY}" = "" ]; then
        title "u26d4  ERROR: Missing AWS credentials: AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY"
        exit 1
    fi

    title "u2705  AWS credentials found"
}

init_local () {
    if [ ! -f ${SSH_KEY_FILE} ]; then
        echo "Creating ssh private/public keys"
        mkdir -p ./ssh_keys
        ssh-keygen -t rsa -b 4096 -N '' -C '' -f ${SSH_KEY_FILE}
    else
        echo "SSH private/public keys exist: ${SSH_KEY_FILE}"
    fi
    echo
}

compile_go_api () {
	cd ${CURR_DIR}/api
	mkdir -p bin
    echo "--> Downloading packages"
	go get -d -u ...
    echo "--> Running tests"
    go test ./...
    echo "--> Compiling binary"
	GOOS=linux go build -o ./bin/app ./cmd/app/main.go
	ls -ahl ./bin/app
	file ./bin/app
}

packer_display_variables () {
    echo "[packer variables]"
    echo "variables" | packer console -var-file=${PARKER_DIR}/variables.json ${PARKER_DIR}/ami.json | sort | xargs -I{} echo "-- {}" | \
    egrep -v "(aws_access_key|aws_secret_key)"
    echo
}

packer_validate () {
    packer validate -var-file=${PARKER_DIR}/variables.json ${PARKER_DIR}/ami.json
}

packer_build () {
    packer build -var-file=${PARKER_DIR}/variables.json ${PARKER_DIR}/ami.json
}

terraform_validate () {
    terraform init ${TERRAFORM_DIR} | grep successfully && echo "OK: Terraform Inited" || echo "Error: Failed to init Terraform"
    terraform validate ${TERRAFORM_DIR}
}

terraform_plan () {
    terraform plan -var="aws_region=${AWS_REGION}" ${TERRAFORM_DIR}
}

terraform_apply () {
    terraform apply -auto-approve -var="aws_region=${AWS_REGION}" ${TERRAFORM_DIR}
}

# main
title "u2699  ${D_PRE} Pre-Check ${D4}${D4}"
check_aws_credentials

echo
title "u2699  ${D_PRE} Init Local ${D4}${D4}"
init_local

echo
title "u2699  ${D_PRE} Compile Go API ${D4}${D}"
compile_go_api

echo
title "u2699  ${D_PRE} Build Image ${D4}${D2}${D}"
cd ${CURR_DIR}
packer_display_variables
packer_validate
packer_build

echo
title "u2699  ${D_PRE} Deploy Infras ${D4}${D}"
cd ${CURR_DIR}
terraform_validate
terraform_plan
terraform_apply

echo
title "u26A1 ${D_PRE} Load Testing API ${D4}${D}"
bash ${CURR_DIR}/infras/scripts/load_test.sh

echo
title "u2705 ${D_PRE} Done ${D4}${D4}${D4}${D2}"