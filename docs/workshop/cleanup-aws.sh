#!/bin/bash

# Cleanup - AWS Resources

## IAM
### Policy 삭제

# Check if ecr-policy exists
echo "## IAM Policy 삭제"
echo ### Checking for ecr-policy
export USERNAME="github-action"
export POLICY_NAME="ecr-policy"

aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME']"

# Detach policy from user (USERNAME="github-action")
if [[ $? -eq 0 ]]; then
  echo Detaching ecr-policy from user $USERNAME
  POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)
  aws iam detach-user-policy --user-name $USERNAME --policy-arn $POLICY_ARN
fi

# Delete policy
if [[ $? -eq 0 ]]; then
  echo Deleting ecr-policy
  aws iam delete-policy --policy-arn $POLICY_ARN
fi

### Access key 삭제

# List access keys for user (USERNAME="github-action")
echo ### Listing access keys for user $USERNAME
aws iam list-access-keys --user-name $USERNAME

# Delete access key
if [[ $? -eq 0 ]]; then
  echo Deleting access key
  ACCESS_KEY_ID=$(aws iam list-access-keys --user-name $USERNAME --query "AccessKeyMetadata[*].AccessKeyId" --output text)
  aws iam delete-access-key --user-name $USERNAME --access-key-id $ACCESS_KEY_ID
fi

### User 삭제

# Delete user (USERNAME="github-action")
echo ### Deleting user $USERNAME
aws iam delete-user --user-name $USERNAME


## ECR

# Set environment variables (replace with your values)
export ECR_REPOSITORY="ci-sample"
export AWS_REGION="ap-northeast-2"

# List ECR repositories
echo "## ECR"
echo ### List repositories
aws ecr describe-repositories

# List images in target repository
echo ### List images in repository: ${ECR_REPOSITORY}
IMAGE_IDS=$(aws ecr list-images --repository-name ${ECR_REPOSITORY} --region ${AWS_REGION} --query 'imageIds[*]' --output json)

# Delete images in target repository
if [[ $? -eq 0 ]]; then
  echo Deleting images in repository: ${ECR_REPOSITORY}
  aws ecr batch-delete-image --region ${AWS_REGION} \
    --repository-name ${ECR_REPOSITORY} \
    --image-ids "$IMAGE_IDS"
fi

# Delete ECR repository
echo ### Deleting repository: ${ECR_REPOSITORY}
aws ecr delete-repository \
  --repository-name ${ECR_REPOSITORY} \
  --region ${AWS_REGION}


## kubeconfig file

# Delete kubeconfig file (run on Cloud9 terminal)
echo "## kubeconfig file"
echo ### Delete kubeconfig file (on Cloud9 terminal)
# This line should be executed on the Cloud9 terminal: rm -rf ~/.kube


## Cloud9 environment deletion

# Delete Cloud9 environments
echo "## Cloud9"
echo ### Delete Cloud9 environments
for env_id in $(aws cloud9 list-environments --query 'environmentIds' --output text); do
  aws cloud9 delete-environment --environment-id "$env_id"
done

echo "## Script completed."
