## Cloud9 IDE 환경 구성


### Cloud9 IDE 생성
AWS 서비스에서 Cloud9을 선택하고, "Create Environments" 버튼을 클릭합니다.  
![cloud9-create](../../images/workshop/cloud9-create.png)

Cloud9 이름과 Descriiption을 설정합니다. 

![create-env](../../images/workshop/create-env.png)

### Cloud9 구성
Instance type을 변경합니다. 

Instance type - Additional instance types - t3.large  
![instance-type](../../images/workshop/instance-type.png)

> [!NOTE]
> Cloud9 하단의 설정 메뉴 중에 Network Setting은 변경하지 않으면, 자동으로 VPC Default로 설정되며 Cloud9 인스턴스는 해당 Default VPC의 public subnet에 자동으로 설치됩니다.

AWS Console에서 Cloud9 생성한 것을 확인합니다.
![cloud9-list](../../images/workshop/cloud9-list.png)

"Open"을 눌러 Cloud9 IDE를 오픈합니다.
![cloud9-landing](../../images/workshop/cloud9-landing.png)

### Cloud9 에 패키지 설치
#### **Kubectl 설치**
EKS를 위한 kubectl 바이너리를 다운로드합니다. Kubernetes 버전 1.23 출시부터 공식적으로 Amazon EKS AMI에는 containerd가 유일한 런타임으로 포함됩니다.
> [!NOTE]
> Amazon EKS 클러스터 제어 영역과 마이너 버전이 하나 다른 kubectl 버전을 사용해야 합니다. 예를 들어 1.28 kubectl 클라이언트는 Kubernetes 1.27, 1.28, 1.29 클러스터와 함께 작동합니다.

```bash
# kubectl download
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.28.5/2024-01-04/bin/linux/amd64/kubectl


# 바이너리에 실행 권한을 적용
chmod +x ./kubectl

# 바이너리를 PATH의 폴더에 복사 및 설정
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

# 자동완성
source <(kubectl completion bash) 
echo "source <(kubectl completion bash)" >> ~/.bashrc

alias k=kubectl
complete -o default -F __start_kubectl k

echo "alias k=kubectl" >> ~/.bashrc
echo "complete -o default -F __start_kubectl k" >> ~/.bashrc

source ~/.bashrc

# kubectl 버전 확인
kubectl version --client
```

#### **Homebrew 설치**
Homebrew는 Apple(또는 Linux 시스템)에서 제공하지 않는 유용한 패키지 관리자를 설치합니다.  

> [!NOTE]
> homebrew설치할때 패스워드 묻기 때문에 미리 설정합니다.

ec2-user 패스워드 설정
```
sudo passwd ec2-user
```

homebrew 설치
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

brew 관련 설정을 profile에 추가합니다.
```bash

(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/ec2-user/.bash_profile

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

설치 확인
```
brew -v
```

#### **Helm 설치**
Helm은 쿠버네티스를 위한 패키지 관리 도구입니다.  

설치 
```
brew install helm
```

설치 확인
```
helm version
```
