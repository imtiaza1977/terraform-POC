#!/bin/bash -e
az login
az account set --subscription "Terraform-Deployment" 

RESOURCE_GROUP_NAME="awspre-infra"
STORAGE_ACCOUNT_NAME="awspresto-infra"
CONTAINER_NAME="awsprestate"
STATE_FILE="terraform.state"

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location koreacentral


# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob


# Get storage account key (Only used if SPN not available)
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)


# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY


echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"
echo "state_file: $STATE_FILE"

# Create keyvault and example of Storing a Key
az keyvault create --name "awspresec" --resource-group "awspre-infra" --location koreacentral
az keyvault secret set --vault-name "awspresec" --name "awsprestateaccess" --value {$ACCOUNT_KEY}
az keyvault secret show --vault-name "awspresec" --name "awsprestateaccess"
