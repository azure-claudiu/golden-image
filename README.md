Golden Image Pipeline
---------------------

# Packer templates included

There are two templates that create a VM image in an Azure subscription. The VM is configured to have the nginx web server installed.

* image1.pkr.hcl - uses just a `shell` provisioner 
* image2.pkr.hcl - uses a `shell` provisioner and an `ansible-local` provisioner

# Running Packer

0. Install [Packer CLI](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli) and [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

1. Log into the Azure account:

```
az login
```

2. Set the desired subscription. Replace the placeholders first.

```
az account set --subscription <subscription_id>
```

3. Create a new resource group, if needed. Replace the placeholders first.

```
az group create -n <resource_group_name> -l eastus
```

4. Create a new service principal that will be able to do everything Packer needs to do. Replace the subscription id.

```
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<subscription_id> --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
```

Be sure to copy the client id and client secret from the output.

5. Supply values for the Packer variables

One way to supply values for Packer variables is to create environment variables in the terminal session where Packer will run. Use the syntax matching your terminal session (e.g. `SET PKR_VAR_abc=xyz`, or `$env:PKR_VAR_abc='xyz'`, or `export PKR_VAR_abc=xyz`, etc.)

```
PKR_VAR_az_sub_id=...
PKR_VAR_az_tenant_id=...
PKR_VAR_az_client_id=...
PKR_VAR_az_client_secret=...
```

If you prefer to not use environment variables, you will need to supply values for the variables when running Packer commands:

```
packer build image3.pkr.hcl -var="az_sub_id=..." -var="az_tenant_id=..." -var="az_client_id=..." -var="az_client_secret=..."
```

6. Run Packer to create the VM image

If you created environment variables for the Packer variables, run this:
```
packer build image2.pkr.hcl
```

If you will not use environment variables, run this instead:
```
packer build image2.pkr.hcl -var="az_sub_id=..." -var="az_tenant_id=..." -var="az_client_id=..." -var="az_client_secret=..."
```

7. Test the image by creating a VM

To create the VM, run the command below. Replace the placeholders first.
```
az vm create -g <rg_name> --name <vm_name> --image <image_name> --admin-username azureuser --generate-ssh-keys
```

8. Test the VM

On the VM you just created, test connectivity to it, either by opening an SSH connection, or opening a port to validate the web server was installed correctly. Replace the placeholders first.

```
az vm open-port -g <rg_name> --name <vm_name> --port 80

az vm show -g <rg_name> -n <vm_name> --query publicIps -d -o tsv
```

Then a browser can be opened to the IP address listed with the command above.
