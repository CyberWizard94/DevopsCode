Understanding Workspaces:
*************************

By default, Terraform has one workspace named "default". You can create additional workspaces to manage different sets of infrastructure resources independently from each other. However, it's important to note that Terraform does not have a built-in feature to list services or resources by workspace directly through a command. Terraform's workspaces manage state files, not directly the services.

Listing Resources in a Workspace:
********************************

1. Switch to the Workspace: First, switch to the workspace for which you want to list the resources.

++++++++++++++++++++++++++++++++++++++++++
terraform workspace select <workspace_name>
++++++++++++++++++++++++++++++++++++++++++

2. List Resources: Once you're in the correct workspace, use the following command to list all resources managed by Terraform in that workspace:

++++++++++++++++++++++++++++++++++++++++++
terraform state list
++++++++++++++++++++++++++++++++++++++++++

Listing All Workspaces:
***********************

++++++++++++++++++++++++++++++++++++++++++
terraform workspace list
++++++++++++++++++++++++++++++++++++++++++

Managing Workspaces:
********************

Create a New Workspace:

++++++++++++++++++++++++++++++++++++++++++
terraform workspace new <new_workspace_name>
++++++++++++++++++++++++++++++++++++++++++

Delete a Workspace (cannot delete the default workspace):

++++++++++++++++++++++++++++++++++++++++++
terraform workspace delete <workspace_name>
++++++++++++++++++++++++++++++++++++++++++