What is the Terraform ternary operator?

A Terraform ternary operator is one which operates on three operators. Syntactically, the ternary operator defines a Boolean condition, a value when the condition is true, and a value when the condition is false. 

```
account_tier = var.environment == "dev" ? "Standard" : "Premium"
```

Use cases:

1. Testing for the existence of a variable’s value
```
var.environment == "" ? "dev" : var.environment
```

If the value of var.environment is an empty string then set its value to “dev”, otherwise use the actual value of var.environment.

2. Configuring settings differently based on certain conditions

If the var.environment value is “dev”, the access tier will be set to “Cool”. Otherwise, it will be “Hot”.

```
resource "azurerm_storage_account" "my_storage" {
  name                            = "stmystorage"
  resource_group_name             = "rg-conditional-demo"
  location                        = "eastus"
  access_tier                     = var.environment == "dev" ? "Cool" : "Hot"
}
```


Example 1: Create a resource using a conditional expression

We can use count meta-argument instructs Terraform to create several similar objects without writing seperate blocks for it

The following example evaluates the value of the add_storage_account Boolean variable.

If it is true, count will be assigned 1. When this happens, an Azure storage account will be created. However, if add_storage_account is false, the count will be zero, and no storage account will be created.

```
variable "add_storage_account" {
  description = "boolean to determine whether to create a storage account or not"
  type        = bool
}

resource "azurerm_storage_account" "my_storage_account" {
  count = var.add_storage_account ? 1 : 0

  resource_group_name      = "rg-conditional-demo"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  name = "stspacelift${count.index}${local.rand_suffix}"
}
```

A typical use case for the for_each argument is to use a map of objects to assign multiple users to a group. A conditional expression can be added to filter out resources that should be added to a group based on their user type.


```
variable "users" {
  description = "A list of users to add"
  type = map(object({
    email     = string,
    user_type = string
  }))
  default = {
    "member1" = {
      email     = "member1@abc.com",
      user_type = "Member"
    },
    "member2" = {
      email     = "member2@abc.com",
      user_type = "Member"
    },
    "guest1" = {
      email     = "guest@abc.com",
      user_type = "Guest"
    }
  }
}

# Get the users from AAD
data "azuread_user" "my_users" {
  for_each = var.users
  	user_principal_name = each.value.email
}

resource "azuread_group" "my_group" {
  display_name     = "mygroup"
  security_enabled = true
}


# Only add users who are members to the group
resource "azuread_group_member" "my_group_members" {
  for_each = { for key, val in data.azuread_user.my_users :
  	key => val if val.user_type == "Member" }

  Group_object_id     = azuread_group.my_group.id
  Member_object_id = data.azuread_user.my_users[each.key].id
}
```

Example 2: Using conditionals to deploy a Terraform module

