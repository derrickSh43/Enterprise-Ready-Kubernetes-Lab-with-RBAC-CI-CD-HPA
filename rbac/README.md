# RBAC Setup for GKE Lab
- **Purpose**: Secure access to `dev`, `prod`, and `monitoring` namespaces.
- **Roles**:
  - `dev-edit`: Full management in `dev` (pods, deployments, services, ingresses).
  - `monitoring-read`: Read-only in `monitoring`.
- **Bindings**:
  - `dev-edit-binding`: Assigns `dev-edit` to user `<your-email>`.
  - `monitoring-read-binding`: Assigns `monitoring-read` to `prometheus` ServiceAccount.
- **Apply**:
  ```bash
  kubectl apply -f dev-edit-role.yaml
  kubectl apply -f dev-edit-binding.yaml