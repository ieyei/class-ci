# Prerequisites

## GitHub 설정
### Git 인증
> [!NOTE]  
> 만약 push 과정에서, username, password 를 매번 넣어야 하는 상황이 번거롭다면 아래와 같이 cache 설정을 통해 지정 된 시간(기본 15분) 동안 cache 기반으로 로그인 가능.
```
git config --global user.name USERNAME
git config --global user.email EMAIL
git config credential.helper store
git config --global credential.helper 'cache --timeout TIME YOU WANT'
```

> [!NOTE]
> github MFA 인증을 사용 하고 있는 경우, personal access token을 만들어 password로 사용.
> personal access token 만드는 방법: [Managing your personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token)

Command line에서 personal access token 사용
```
$ git clone https://github.com/USERNAME/REPO.git
Username: YOUR_USERNAME
Password: YOUR_PERSONAL_ACCESS_TOKEN
```
### CI 파이프라인을 위한 AWS IAM 생성 및 policy 설정
sample app을 빌드 하고, docker image로 만든 다음 ECR에 push 하는 과정은 `gitHub Action`을 통해 이루어지며 이 때 least privilege 정책에 따른 IAM User 생성.

#### IAM User 생성
```
aws iam create-user --user-name github-action
```

#### ECR Policy 생성
ecr-policy.json 이름으로 policy 생성.

```
cd ~/environment
cat <<EOF> ecr-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPush",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload"
            ],
            "Resource": "arn:aws:ecr:${AWS_REGION}:${ACCOUNT_ID}:repository/demo-frontend"
        },
        {
            "Sid": "GetAuthorizationToken",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF
```

`ecr-policy` 이름으로 IAM policy 생성.
```
aws iam create-policy --policy-name ecr-policy --policy-document file://ecr-policy.json
```

#### ECR policy를 IAM user에 부여
IAM user에게 새로 생성한 ecr-policy 할당.
```
aws iam attach-user-policy --user-name github-action --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/ecr-policy
```

### AWS Credential 생성 및 설정
gitHub action에서 사용할 AWS credential 생성 및 설정.

**AWS Credential 생성**  
앞 단계에서 생성한 IAM User의 Access Key, Secret Key 생성.
```
aws iam create-access-key --user-name github-action
```
출력 결과의 `SecretAccessKey`, `AccessKeyId` 값은 따로 저장.
```
{
  "AccessKey": {
    "UserName": "github-action",
    "Status": "Active",
    "CreateDate": "xxx",
    "SecretAccessKey": "***",
    "AccessKeyId": "***"
  }
}
```
> [!NOTE]
> `SecretAccessKey`, `AccessKeyId` 값은 최초 생성 할 때만 확인 가능.

**AWS Credential 설정**
Repository 상단 `Settings` 클릭 후 좌측 메뉴 `Secrets and variables > Actions` 클릭.  
`New repository secret` 버튼을 클릭하여 앞서 저장한 IAM User `github-action`의 `SecretAccessKey`, `AccessKeyId` 값을 Secret에 저장.  

AWS_ACCESS_KEY_ID  
AWS_SECRET_ACCESS_KEY  




## AWS Route53

## Certification
