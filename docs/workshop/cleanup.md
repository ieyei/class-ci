# Cleanup - AWS Resources

## IAM
### Policy 삭제
ecr-policy 확인
```bash
aws iam list-policies --query 'Policies[?PolicyName==`ecr-policy`]'
```

detach policy from user
```bash
export USERNAME="github-action"
export POLICY_NAME="ecr-policy"
POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)

aws iam detach-user-policy --user-name $USERNAME --policy-arn $POLICY_ARN
```

policy 삭제
```bash
aws iam delete-policy --policy-arn $POLICY_ARN
```

### Access key 삭제
key list 조회
```bash
aws iam list-access-keys --user-name $USERNAME
```

```bash
ACCESS_KEY_ID=$(aws iam list-access-keys --user-name $USERNAME --query "AccessKeyMetadata[*].AccessKeyId" --output text)

aws iam delete-access-key --user-name $USERNAME --access-key-id $ACCESS_KEY_ID
```

### User 삭제
```bash
aws iam delete-user --user-name $USERNAME
```

## ECR
`Lab Location`: :cloud:
ECR Repository 삭제
```bash
export ECR_REPOSITORY="ci-sample"
export AWS_REGION="ap-northeast-2"

aws ecr describe-repositories
```

image 조회
```bash
# list image
aws ecr list-images --repository-name ${ECR_REPOSITORY} --region ${AWS_REGION} --query 'imageIds[*]' --output text
```
image 삭제
```bash
IMAGE_IDS=$(aws ecr list-images --repository-name ${ECR_REPOSITORY} --region ${AWS_REGION} --query 'imageIds[*]' --output json)

aws ecr batch-delete-image --region ${AWS_REGION} \
  --repository-name ${ECR_REPOSITORY} \
  --image-ids "$IMAGE_IDS"
```

repository 삭제
```bash
aws ecr delete-repository \
--repository-name ${ECR_REPOSITORY} \
--region ${AWS_REGION}
```

## kubeconfig file
`Lab Location`: :cloud:
cloud9 terminal 에서 실행
```bash
rm -rf ~/.kube
```

## Cloud9 삭제

```bash
for env_id in $(aws cloud9 list-environments --query 'environmentIds' --output text); do
    aws cloud9 delete-environment --environment-id "$env_id" --force
done
```
---
# Cleanup - GibHub Resources
## GitHub SSH keys 삭제
`Lab Location`: :octocat:

경로: GitHub 페이지 - 우측 상단 profile - Settings - Settings 상세페이지 좌측 Access - `SSH and GPG keys`
등록한 키 삭제
