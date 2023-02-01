<img align='right' src=".github/cover.png" style='width: 100%; margin-bottom: 20px; border-radius: 4px'>

<div align='center'>
<h1>Deploy React app na AWS ECS com Terraform</h1>
</div>


Neste laboratório iremo realizar um deploy de uma aplicação React com Vite em Docker no ECS da AWS. Utilizaremos o Terraform para provisionar a infraestrutura básica da nossa aplicação.

### 1. AWS ECR
Para armazenar a imagem da aplicação React, iremos realizar o push  para um repositório do ERC. 
Neste passo, não irei provisionar o repositório ERC utilizando o terraform, pois como e algo bem simples, e isolado, preferi utilizar apenas a [CLI da AWS](https://docs.aws.amazon.com/cli/latest/reference/ecr/index.html), mas nada impede de prosseguir utilizando o
`aws_ecr_repository` [resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) do terraform. Lembrando que para seguir com os seguintes passo, é preciso ter o AWS CLI configurado corretamente no terminal ou CMD.

##### Criando o repositório
```
aws ecr create-repository \
    --repository-name react-app \
    --image-tag-mutability MUTABLE
```
Este comando ira retornar algo semelhante a isso
```json
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:us-east-1:XXXXXXXXXXXX:repository/react-app",
        "registryId": "XXXXXXXXXXXX",
        "repositoryName": "react-app",
        "repositoryUri": "XXXXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/react-app",
        "createdAt": 1675190077.0,
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}
```
O Importante nesto bloco é o `repositoryUri`

### 2. Executando o React App no container
Neste laboratório não irei ensinar a como iniciar uma aplicação React com Vite, vou considerar que você já sabe o procedimento de olhos fechados. Após criar a aplicação, vamos criar um Arquivo Dockerfile na raiz pasta da aplicação, e inserir o seguinte manifesto:

```Dockerfile
FROM node:current-alpine3.17 AS builder
RUN mkdir /usr/app
COPY . /usr/app
WORKDIR /usr/app
RUN npm install

# add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH
RUN npm run build

FROM nginx:alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder usr/app/dist .
EXPOSE 80

# Containers run nginx with global directives and daemon off
ENTRYPOINT ["nginx", "-g", "daemon off;"]
```

#### Buildando e testando a imagem
Siga os seguintes passos para realizar o build da imagem:
```docker
docker build -t react-app:latest .
```
Após fazer o build da imagem, execute:
```bash
docker container run -d -p 80:80 --name react-app react-app:latest
```
Acesse `http://localhost:80` e verifique se a aplicação está roando corretament.

### 3. Subindo a imagem pro AWS ECR
Após ter criado o repositório via CLI, podemos vê-lo no Console da AWS. Dentro dele, vemos que não ha imagens. No canto superior direito, vemos um botão `View push commands`, nele tem o passo a passo para fazer o push para o repositório. Siga estes passos corretamente. Após seguir todos os passos, atualize a página e verifique se a sua imagem foi registrada no repositório.


### 4. Baixando arquivos terraform
Faça o clone deste repositório no seu setup
```bash
git clone https://github.com/devpolatto/React_app-ECS.git
```
#### Iniciando com o terraform
Primeiro vamos definir o arquivo main para podermos setar o terraform e definir o backend
```terraform
# main.tf

terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    key    = "terraform.tfstate"
  }
}
provider "aws" {
  region  = local.region
  profile = local.profile
}
```

Observe que estamos utilizando o argumento local para inserir valores sensíveis que não podem estar na linha do tempo do git. Abaixo estão as variáveis local que estão sendo utilizadas neste laboratório. Preencha com as informações da sua infraestrutura cloud.
```tf
locals {
  region = "us-east-1"
  profile = ""
  vpc_id = ""
  igw_id = ""
}
```
**OBS**: Não irei construir uma VPC do zero, pois não e o objetivo neste laboratório. Basta ter uma VPC e um internet-gateway prontos na AWS


#### Backend

Neste laboratório, armazenaremos o terraform.state em um Bucket S3.
Como não é permitido o uso de variáveis em um bloco backend, podemos definir os valores de configuração em um arquivo `.conf`, da seguinte forma:

```
# file.conf 

region="us-east-1"
profile="aws credencials "
bucket="bucket name"
``` 
Com o arquivo de configuração definido, podemos iniciar o terraform:
```
terraform init -backend-config=file.conf
```

