# `shortrib.dev` DNS Automation

Creates the necessary GCP objects to manage DNS for `shortrib.dev`

Reuses code from [Hashicorp's example](https://github.com/hashicorp/vault-guides/tree/master/operations/gcp-kms-unseal).

## Using this Repository

### Prepare a Service Account

To prepare a service account to execute these templates, execute the following steps:

1. Create a service account:

    ```bash
    gcloud iam service-accounts create terraform-dns-shortrib-dev \
        --display-name "shortrib.dev DNS management account"

    gcloud iam service-accounts list
    ```

    Set the `$SERVICE_ACCOUNT_EMAIL` variable to match its `email` value.

    ```bash
    SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list \
      --filter="displayName:shortrib.dev DNS management account" \
      --format 'value(email)')
    ```

3. Assign roles to enable the account to execute

    ```bash
    PROJECT_ID=$(gcloud config get-value project)

    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
        --role roles/dns.admin

4. Create the service account key and output the file to the `secrets` directory. 

    ```bash
    gcloud iam service-accounts keys create ${SECRETS_DIR}/terraform-dns-shortrib-dev.json \
        --iam-account $SERVICE_ACCOUNT_EMAIL
    ```

### Prepare a bucket for remote state storage

To maintain Terraform state across systems and users, we'll use GCP to store the remote state.

1. Create the bucket

```bash
BUCKET=$(basename $(pwd))    # or whatever you fancy

gsutil mb gs://${BUCKET}
gsutil versioning set on gs://${BUCKET}
```

2. Enable access

```bash
gsutil iam ch serviceAccount:${SERVICE_ACCOUNT_EMAIL}:objectAdmin gs://${BUCKET}
```

### Check the variables

Review the values of the Terraform values set in `.envrc` and in [`src/terraform/terraform.tfvars`](src/terraform/terraform.tfvars).

### Create or update the infrastructure

```bash
cd src/terraform
terraform apply

```

## Directory Structure


* `bin`: Useful scripts for working with the project. There's one
  script common to all projects  to simplify encrypting and 
  decryting project secrets. The `direnv` configuration in the
  template `.envrc` file add this to `PATH` for ease of use.
* `secrets`: Directory for storing project secrets. They should only
  be added to git when encrypted. The `secrets` script allows for 
  easy encrypt/decrypt using GPG.
* `src`: Project source code 
* `work`: For working files that should not be added the repo. Any
  script in the project can depend on this directory being there 
  for working storage.
