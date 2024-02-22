# Create CI pipeline

## GitHub Action
### GitHub Repo name 설정
```
export GIT_REPO_NAME='MSA_REF_PATTERN'
```

### `.github` 디렉토리 생성
```
cd ~/environment/$GIT_REPO_NAME
mkdir -p ./.github/workflows
```

### github action이 사용할 build.yaml 생성
순서: checkout -> build -> push

cloud9에서 $ECR_REPOSITORY 설정 필요!!!!!

**main-build.yaml for V1 [main branch]**
```
cd ~/environment/$GIT_REPO_NAME/.github/workflows
cat > main-build.yaml <<EOF

name: Build Main

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ "main" ]
      
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source code
        uses: actions/checkout@v3

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: \${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: $AWS_REGION

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push image to Amazon ECR
        id: image-info
        env:
          ECR_REGISTRY: \${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: $ECR_REPOSITORY
          IMAGE_TAG: v1
        run: |
          echo "::set-output name=ecr_repository::\$ECR_REPOSITORY"
          echo "::set-output name=image_tag::\$IMAGE_TAG"
          ./gradlew -p MSA_REF_BIZ_ORDER clean build
          cp ./MSA_REF_BIZ_ORDER/build/libs/*.jar ./app.jar
          docker build -t \$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG .

      - name: Run Trivy vulnerability scanner
        env:
          ECR_REGISTRY: \${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: \${{ steps.image-info.outputs.ecr_repository }}
          IMAGE_TAG: \${{ steps.image-info.outputs.image_tag }}      
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: \$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG
          format: 'table'
          exit-code: '0'
          ignore-unfixed: true
          vuln-type: 'os,library'
          severity: 'CRITICAL,HIGH'
          
      - name: Push image to Amazon ECR
        id: image-push
        env:
          ECR_REGISTRY: \${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: \${{ steps.image-info.outputs.ecr_repository }}
          IMAGE_TAG: \${{ steps.image-info.outputs.image_tag }}
        run: |
          echo "::set-output name=ecr_repository::\$ECR_REPOSITORY"
          echo "::set-output name=image_tag::\$IMAGE_TAG"
          docker push \$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG          

EOF
```

**dev-build.yaml for V2 [dev branch]**
```
cd ~/environment/amazon-eks-frontend/.github/workflows
cat > dev-build.yaml <<EOF

name: Build Dev

on:
  push:
    branches: [ dev ]
    paths:
      - MSA_REF_BIZ_ORDER/**
      
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source code
        uses: actions/checkout@v3

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: \${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: $AWS_REGION

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push image to Amazon ECR
        id: image-info
        env:
          ECR_REGISTRY: \${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: $ECR_REPOSITORY
          IMAGE_TAG: v2
        run: |
          echo "::set-output name=ecr_repository::\$ECR_REPOSITORY"
          echo "::set-output name=image_tag::\$IMAGE_TAG"
          ./gradlew -p MSA_REF_BIZ_ORDER clean build
          cp ./MSA_REF_BIZ_ORDER/build/libs/*.jar ./app.jar
          docker build -t \$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG .
          docker push \$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG

EOF
```

**Sample build.yaml**
```
cd ~/environment/amazon-eks-frontend/.github/workflows
cat > build.yaml <<EOF

name: Build Front

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source code
        uses: actions/checkout@v3

      - name: Check Node v
        run: node -v

      - name: Build front
        run: |
          npm install
          npm run build

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: \${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: $AWS_REGION

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Get image tag(verion)
        id: image
        run: |
          VERSION=\$(echo \${{ github.sha }} | cut -c1-8)
          echo VERSION=\$VERSION
          echo "::set-output name=version::\$VERSION"

      - name: Build, tag, and push image to Amazon ECR
        id: image-info
        env:
          ECR_REGISTRY: \${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: demo-frontend
          IMAGE_TAG: \${{ steps.image.outputs.version }}
        run: |
          echo "::set-output name=ecr_repository::\$ECR_REPOSITORY"
          echo "::set-output name=image_tag::\$IMAGE_TAG"
          docker build -t \$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG .
          docker push \$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG

EOF
```

### GitHub Action workflow 확인
1. Code를 push하여 github action workflow 실행.
```
cd ~/environment/$GIT_REPO_NAME
git add .
git commit -m "Add github action build script"
git push origin main
```
2. Browser에서 `run workflow` 버튼 클릭하여 실행.

정상 build 확인 후 image가 ECR에 제대로 push 되었는지 확인.
