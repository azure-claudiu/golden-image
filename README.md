Golden Image &#x1FA99; Pipeline
---------------------

# Packer templates included

There are different Packer templates that create a VM image in an Azure subscription. In all cases the VM is configured to have the nginx web server installed and running on port 80.

## T.1 - image1.pkr.hcl
* uses a `shell` provisioner
* is the simplest, because it does everything with commands run locally

## T.2 - image2.pkr.hcl
* uses a `shell` provisioner, and an `ansible-local` provisioner
* the shell provisioner is needed to install Ansible locally, so that the `ansible-local` provisioner can later run successfully
* a final shell provisioner can be used to uninstall Ansible

## T.3 - image3.pkr.hcl
* uses an `ansible` provisioner
* Ansible has to be installed on the machine where Packer is run
* if encountering a 'failed to handshake' error while the Ansible playbook runs, see a fix in the references section.

# Azure prerequisites

Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) if you wish to run these Azure setup steps on a new machine. Azure CLI is not needed for Packer to run. So if the setup steps have run on a different machine, or from the Portal, don't install Azure CLI on the machine where you'll be running Packer from.

Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) if running the template that uses the `ansible` provisioner, because the node you're running Packer from will act as an Ansible control node.

## A.1 - Log into the Azure account

```
az login
```

## A.2 - Set the desired subscription

Replace the placeholder first.

```
az account set --subscription <subscription_id>
```

## A.3 - Create a new resource group, if needed

Replace the placeholder first.

```
az group create -n <resource_group_name> -l eastus
```

## A.4 - Create a new service principal

The service principal is needed for Packer to be able to perform actions in the Azure subscription.

Replace the placeholder first.

```
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<subscription_id> --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
```

Be sure to copy (save) the tenant id, client id, and client secret from the output.

# Running Packer

Install [Packer CLI](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli) to be able to run the Packer templates.

## P.1 - Supply values for the Packer variables

One way to supply values for Packer variables is to create environment variables in the terminal session where Packer will run. Use the syntax matching your terminal session (e.g. `SET PKR_VAR_abc=xyz`, or `$env:PKR_VAR_abc='xyz'`, or `export PKR_VAR_abc=xyz`, etc.)

Set the following environment variables, using the values from the Azure prerequisite steps above.

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

## P.2 - Run Packer to create the VM image

If you created environment variables for the Packer variables, run this:
```
packer build image2.pkr.hcl
```

If you will not use environment variables, run this instead:
```
packer build image2.pkr.hcl -var="az_sub_id=..." -var="az_tenant_id=..." -var="az_client_id=..." -var="az_client_secret=..."
```

## P.3 - Test the image by creating a VM

To create the VM, run the command below. Replace the placeholders first.
```
az vm create -g <rg_name> --name <vm_name> --image <image_name> --admin-username azureuser --generate-ssh-keys
```

You should get the public IP address of the VM from the output of the command above. If you lose this IP address, you can retrieve it with the command below. Replace the placeholders first.

```
az vm show -g <rg_name> -n <vm_name> --query publicIps -d -o tsv
```

## P.4 - Test the VM

On the VM you just created, test connectivity to it, by either:
* opening an SSH connection to the public IP, or
* opening a browser to its public IP (e.g. http://<public-ip>) to validate the web server was installed correctly

To open access to port 80 on the VM, you can use the portal, or the script below. Replace the placeholders first.

```
az vm open-port -g <rg_name> --name <vm_name> --port 80
```

Then a browser can be opened to the public IP address listed in the section above.

# References

* [Shell provisioner](https://developer.hashicorp.com/packer/docs/provisioners/shell)
* [Ansible (Local) provisioner](https://developer.hashicorp.com/packer/plugins/provisioners/ansible/ansible-local)
* [Ansible (Remote) provisioner](https://developer.hashicorp.com/packer/plugins/provisioners/ansible/ansible)
* [Building Linux images with Packer](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer)
* [Building Windows images with Packer](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/build-image-with-packer)
* [Fix for Ansible remote provisioner error](https://www.bojankomazec.com/2022/10/how-to-fix-ansible-error-failed-to.html)
