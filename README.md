# Folding@Azure

## My Folding Journey

I discovered Folding@Home from the following [blog](https://foldingathome.org/2020/03/10/covid19-update/) while I was sat at my Mother's one Sunday afternoon after helping with the shopping. My Mother having Asthma & COPD, my Father with diabetes and my Step-Father who suffered a bad stroke late last year all fall within the high-risk category. I decided to do my part and see if I could get this up and running on my home PC. Five minutes later I was connected and my PC was completing a folding project on to helping to find therapeutic opportunities for COVID-19. You can repeat this with any machine you have at home by going to [Folding@Home](https://foldingathome.org/start-folding/).

I then thought how could I take this one step further and combine this with my other work expertise. I set out on the following Saturday afternoon to see if I could get a repeatable deployment running on Azure. Using my Azure MSDN subscription I believe this is the first terraform based deployment. This deployment doesn't require you to login and setup the Azure VM that is completed for you. All that is required is a few code edits and a terraform apply and that's it your up and running. I admit I am not the first to do this and there are some other fantastic github projects as well.

- [CORONAFOLD](https://github.com/CentareGroup/folding-at-centare)
- [Folding on AKS](https://github.com/cmilanf/docker-foldingathome)

## Setup

Terraform to setup Folding@Home instances in Azure.

## Prerequisites

1. An [Azure account](https://azure.microsoft.com/en-us/free/). I used an MSDN subscription for this. With the Azure Free Subscription you will have £150 credits that will allow you to running a Standard F4s_v2 VMs for 24x7 for one month.
1. A [Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) with Contributor rights over your Azure Subscription.
1. Install [Terraform](https://www.terraform.io/downloads.html).
1. Install [Git](https://git-scm.com/downloads).

## Getting Started

1. Clone the repo to your machine.
1. Edit the terraform.tfvars file.
1. Edit the cloud-init.yaml file to configure the folding at home client.
1. Run terraform init
1. Run terraform apply
1. Terraform will output the hostname for the folding VMs in Azure. These can be accessed at http://hostname:7396

## Edit the terraform.tfvars file

Open the file with your editor of choice (VS Code recommended) Fill in your values in between the quotations.

    tenant_id = "" //Your Azure Tenant ID
    subscription_id = "" //Your Azure Subscription ID
    client_id = "" //Your Service Principal Client ID
    client_secret = "" //Your Service Principal Sercret
    location = "" //Azure Region to deploy to. I chose West Europe
    clientip = "" //Your Public IP you will be viewing your folding from
    fahvmusername = "" //Username used to login to the linux VM
    fahvmpassword = "" //Password used to login to the linux VM

## Updating the cloud-init.yaml

1. **User:** This can be any unique identifier that you want to use to track your work contribution. [Read more about users](https://foldingathome.org/support/faq/stats-teams-usernames/).
1. **Team:** The team that you want to associate your work with. My Team is 246715. [Read more about teams](https://foldingathome.org/support/faq/stats-teams-usernames/).
1. **Passkey:** A unique identifier that ties your contributions directly to you (not just those with your username). [Read more about passkeys](https://foldingathome.org/support/faq/points/passkey/).
1. **GPU:** Set value to true if using an nvidia based Azure VM. Recommended SKU is the NCv3-series, otherwise use the F2-series.
1. **Allow:** Replace x.x.x.x with your public IP to be able to view your host with a web browser. To find out what your public IP is use this handy little [website](https://www.whatismyip.com/).
1. **Web-Allow:** Replace x.x.x.x with your public IP to be able to view your host with a web browser.
1. **Password:** Set A Password to remotely manage the FAHClient with FAHControl. Download from [here](https://foldingathome.org/alternative-downloads/).
