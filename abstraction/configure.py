# configure.py
import json
import os

def get_input(prompt, default=None):
    value = input(f"{prompt} {f'[{default}]' if default else ''}: ").strip()
    return value if value else default

def get_bool_input(prompt):
    while True:
        value = input(f"{prompt} (yes/no): ").lower()
        if value in ['yes', 'y']:
            return True
        elif value in ['no', 'n']:
            return False
        print("Please enter 'yes' or 'no'")

def get_list_input(prompt):
    items = []
    print(f"\n{prompt} (Enter empty line when done):")
    while True:
        item = input("> ").strip()
        if not item:
            break
        items.append(item)
    return items

def get_permissions():
    permissions = {}
    
    # Cluster permissions
    if get_bool_input("Do you want to add cluster permissions?"):
        permissions["cluster_permissions"] = get_list_input("Enter cluster permissions")
    
    # Index permissions
    if get_bool_input("Do you want to add index permissions?"):
        index_permissions = []
        while True:
            index_patterns = get_list_input("Enter index patterns")
            allowed_actions = get_list_input("Enter allowed actions")
            
            index_permissions.append({
                "index_patterns": index_patterns,
                "allowed_actions": allowed_actions
            })
            
            if not get_bool_input("Add more index permissions?"):
                break
        permissions["index_permissions"] = index_permissions
    
    # Tenant permissions
    if get_bool_input("Do you want to add tenant permissions?"):
        tenant_permissions = []
        while True:
            tenant_patterns = get_list_input("Enter tenant patterns")
            allowed_actions = get_list_input("Enter allowed actions")
            
            tenant_permissions.append({
                "tenant_patterns": tenant_patterns,
                "allowed_actions": allowed_actions
            })
            
            if not get_bool_input("Add more tenant permissions?"):
                break
        permissions["tenant_permissions"] = tenant_permissions
    
    return permissions

def main():
    config = {
        "opensearch_endpoint": get_input("Enter OpenSearch endpoint"),
        "aws_region": get_input("Enter AWS region", "us-east-1"),
        "application_config": {
            "name": get_input("Enter application name"),
            "access_control": {}
        }
    }

    while True:
        role_name = get_input("Enter role name")
        if not role_name:
            break

        role_config = {}
        
        # User creation
        role_config["create_user"] = get_bool_input("Do you want to create a user for this role?")
        if role_config["create_user"]:
            role_config["password"] = get_input("Enter password for the user")

        # Role creation
        role_config["create_role"] = get_bool_input("Do you want to create a custom role?")
        if role_config["create_role"]:
            role_config["permissions"] = get_permissions()
        else:
            role_config["existing_role"] = get_input("Enter existing role name")

        # Backend roles
        role_config["backend_roles"] = get_list_input("Enter backend roles (IAM roles)")

        config["application_config"]["access_control"][role_name] = role_config

        if not get_bool_input("Do you want to add another role?"):
            break

    with open("terraform.auto.tfvars.json", "w") as f:
        json.dump(config, f, indent=2)

if __name__ == "__main__":
    main()
