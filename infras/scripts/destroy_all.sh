#!/bin/bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

ctrl_c () {
    echo "** Trapped CTRL-C"
}

TERRAFORM_DIR="./infras/terraform"

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

terraform_destroy_all () {
    terraform init ${TERRAFORM_DIR} | grep successfully && echo "OK: Terraform Inited" || echo "Error: Failed to init Terraform"
    terraform destroy -auto-approve -refresh=false -var="aws_region=${AWS_REGION}" ${TERRAFORM_DIR}
}

deregister_all_api_images () {
    IMAGES=`aws ec2 describe-images --filter "Name=tag:Release,Values=api-latest" | jq -rc '.Images[] | {Name, ImageId}'`

    for I in ${IMAGES}
    do
        NAME=`echo ${I} | jq -r '.Name'`
        ID=`echo ${I} | jq -r '.ImageId'`
        echo "Deregistering AMI: ${NAME}"
        aws ec2 deregister-image --image-id ${ID}
    done
}

delete_all_api_snapshots () {
    SNAPSHOTS=`aws ec2 describe-snapshots --filter "Name=tag:Release,Values=api-latest" | jq -rc '.Snapshots[].SnapshotId'`

    for S in ${SNAPSHOTS}
    do
        echo "Deleting Snapshot: ${S}"
        aws ec2 delete-snapshot --snapshot-id ${S}
    done
}

# main
title "u2699  ${D_PRE} Pre-Check ${D4}${D4}${D4}${D4}${D2}"
check_aws_credentials

echo
title "u2699  ${D_PRE} Terraform Destroy ${D4}${D2}${D4}"
terraform_destroy_all

echo
title "u2699  ${D_PRE} Deregistering AMI Images ${D2}${D}"
deregister_all_api_images

echo
title "u2699  ${D_PRE} Deleting Snapshots ${D4}${D4}${D}"
delete_all_api_snapshots

echo
title "u2705 ${D_PRE} Done ${D4}${D4}${D4}${D4}${D4}${D2}${D}"