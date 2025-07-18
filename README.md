# Terraform Bootstrap

Este projeto define a infraestrutura base necessária para usar **Terraform com backend remoto na AWS**, incluindo:

- Bucket S3 para armazenar o `terraform.tfstate`
- Tabela DynamoDB para controle de lock
- Pipeline GitHub Actions reutilizável via `workflow_call`

---

## 📌 Objetivo

Fornecer uma base reutilizável para projetos Terraform que necessitam de backend remoto na AWS. Com este repositório, você pode:

- Provisionar o backend (bucket + DynamoDB) com um clique ou pipeline automatizada
- Padronizar a criação de infraestrutura básica entre projetos
- Facilitar o onboarding de novos repositórios e ambientes

---

## 📦 Recursos Provisionados

| Tipo            | Nome padrão                              | Observações importantes                                                  |
|-----------------|-------------------------------------------|--------------------------------------------------------------------------|
| S3 Bucket       | `tf-state-<environment>`                 | Versão + criptografia + tags + bloqueio público + ownership controls    |
| DynamoDB Table  | `terraform-locks-<environment>`          | Para evitar race conditions no Terraform state                          |

---

## 📁 Estrutura do Repositório

```bash
terraform-bootstrap/
├── main.tf               # Código principal do Terraform
├── variables.tf          # Variáveis do projeto
├── outputs.tf            # Outputs se necessário
├── terraform.tfvars      # (Opcional) Para uso local
├── .github/
│   └── workflows/
│       └── bootstrap.yml # Workflow reutilizável por outros projetos
└── README.md             # Este arquivo
```
---

## 🚀 Como Usar

### ✅ Requisitos
- Conta AWS com credenciais válidas (Access Key + Secret)
- Terraform CLI
- Permissões para rodar workflows no GitHub

### 🧪 Uso Local (Manual)

```bash
terraform init
terraform plan \
  -var="bucket_name=tf-state-dev" \
  -var="dynamodb_table_name=terraform-locks-dev" \
  -var="environment=dev"
terraform apply -auto-approve \
  -var="bucket_name=tf-state-dev" \
  -var="dynamodb_table_name=terraform-locks-dev" \
  -var="environment=dev"
```
### 🔁 Uso via GitHub Actions `workflow_call`
#### Você pode reutilizar este pipeline de bootstrap em qualquer outro projeto Terraform. Crie um workflow como abaixo no projeto consumidor:

```bash
# .github/workflows/bootstrap.yml em outro projeto
name: Infra Bootstrap

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Ambiente (dev, staging, prod)'
        required: true
      region:
        description: 'AWS region (ex: us-east-1)'
        required: true

jobs:
  call-bootstrap:
    uses: vinicius3516/terraform-bootstrap/.github/workflows/bootstrap.yml@main
    with:
      environment: ${{ github.event.inputs.environment }}
      region: ${{ github.event.inputs.region }}
    secrets:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```
> **Importante:**
> Substitua `vinicius3516` pelo nome correto da organização ou conta GitHub, se caso você tenha feito um `Fork` do projeto.

---

## ⚙️ Inputs disponíveis no `workflow_call`

| Nome        | Tipo    | Obrigatório | Descrição                                      |
|-------------|---------|-------------|------------------------------------------------|
| environment | string  | ✅          | Nome do ambiente (dev, staging, prod)          |
| region      | string  | ✅          | Região AWS onde os recursos serão criados      |

---

## 🔐 Secrets necessárias

| Nome                 | Descrição                                                   |
|----------------------|-------------------------------------------------------------|
| `AWS_ACCESS_KEY_ID`  | Access key de uma IAM user com permissão                    |
| `AWS_SECRET_ACCESS_KEY` | Secret key correspondente                               |

> **Importante:**  
> Você deve configurar esses secrets **no repositório que chama o bootstrap** (não no bootstrap em si):  
> Vá para `Settings > Secrets and variables > Actions` e adicione os dois secrets lá.

---

## 🛡️ Boas práticas implementadas no backend S3

O bucket provisionado pelo `terraform-bootstrap` é configurado com diversas proteções e práticas recomendadas pela AWS:

| Recurso                     | Descrição                                                                 |
|----------------------------|---------------------------------------------------------------------------|
| 🔐 Criptografia AES256      | Todos os arquivos no bucket são criptografados automaticamente            |
| 🚫 Bloqueio de acesso público | Nenhuma ACL ou política pode tornar o bucket ou objetos públicos           |
| 👤 Ownership Controls       | O bucket sempre será dono dos objetos enviados, mesmo via STS ou terceiros |
| 📜 Versionamento ativado   | Cada alteração no state é versionada automaticamente                      |
| 🏷️ Tags padronizadas        | Tags como `Environment` e `ManagedBy` são aplicadas de forma consistente    |


---

## 🤝 Contribuindo

Pull requests são bem-vindos!  
Se você quiser propor melhorias, criar novos módulos ou estender o suporte a múltiplas regiões/contas, sinta-se à vontade.

---

## 📄 Licença

Este projeto está sob a licença **MIT**.

---

## 💬 Dúvidas?

Abra uma issue ou entre em contato com o mantenedor do projeto.
