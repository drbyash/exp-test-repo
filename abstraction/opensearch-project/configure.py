# configure.py
import json

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
    print("\nCluster Permissions:")
    print("Common permissions: cluster:monitor/*, cluster:admin/*, cluster_all")
    permissions["cluster_permissions"] = get_list_input("Enter cluster permissions")
    
    # Index permissions
    print("\nIndex Permissions:")
    print("Common patterns: app-*, app-logs-*, app-data-*")
    print("Common actions: indices:*, indices:admin/*, indices:data/read*, indices:data/write*")
    
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
        print("\nTenant Permissions:")
        print("Common patterns: private_tenant_*, shared_tenant_*")
        print("Common actions: kibana_all_read, kibana_all_write")
        
        tenant_permissions = []
        tenant_patterns = get_list_input("Enter tenant patterns")
        tenant_actions = get_list_input("Enter tenant actions")
        
        tenant_permissions.append({
            "tenant_patterns": tenant_patterns,
            "allowed_actions": tenant_actions
        })
        permissions["tenant_permissions"] = tenant_permissions
    
    return permissions

def main():
    config = {
        "application_config": {
            "name": get_input("Enter application name"),
            "access_control": {}
        }
    }

    while True:
        role_name = get_input("Enter role name (e.g., admin, readonly, developer)")
        if not role_name:
            break

        role_config = {}
        
        # User creation
        role_config["create_user"] = get_bool_input("Do you want to create a user for this role?")
        if role_config["create_user"]:
            while True:
                password = get_input("Enter password for the user (min 8 chars, must include upper, lower, number, special)")
                if len(password) >= 8 and any(c.isupper() for c in password) and \
                   any(c.islower() for c in password) and any(c.isdigit() for c in password) and \
                   any(not c.isalnum() for c in password):
                    role_config["password"] = password
                    break
                print("Password does not meet requirements. Please try again.")

        # Role creation
        role_config["create_role"] = get_bool_input("Do you want to create a custom role?")
        if role_config["create_role"]:
            role_config["permissions"] = get_permissions()
        else:
            print("\nAvailable default roles:")
            print("- readall (read access to all indices)")
            print("- security_manager (security configuration access)")
            print("- super_admin (full access)")
            role_config["existing_role"] = get_input("Enter existing role name")

        # Backend roles
        print("\nBackend Roles (IAM ARNs):")
        print("Format: arn:aws:iam::123456789012:role/RoleName")
        role_config["backend_roles"] = get_list_input("Enter backend roles")

        config["application_config"]["access_control"][role_name] = role_config

        if not get_bool_input("Do you want to add another role?"):
            break

    # Write configuration to file
    with open("terraform.auto.tfvars.json", "w") as f:
        json.dump(config, f, indent=2)

if __name__ == "__main__":
    main()