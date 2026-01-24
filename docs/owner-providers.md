
# Owner Providers

## Overview

Owner providers in the Authority system represent the resource owners—typically the users who own the data or resources being accessed. They play a crucial role in controlling access to their resources.

## Configuring Owner Providers

To configure an owner provider, you need to establish ownership models in your application. This usually involves mapping user records to resources that they own.

### Example Configuration

In your database schema, make sure that resources have an `owner_id` field that corresponds to the user who owns the resource.

```sql
CREATE TABLE resources (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER REFERENCES users(id)
);
```

## Using Owner Providers

Once the ownership structure is in place, you can enforce access control rules by checking whether the current authenticated user is the owner of the resource they are trying to access.

Example in Crystal:
```crystal
# Assuming `current_user` is the authenticated user and `resource` is the requested resource.
if resource.owner_id == current_user.id
  # Allow access
else
  # Deny access
end
```

Owner providers help implement fine-grained access control mechanisms, ensuring that users can only access the resources they own.
