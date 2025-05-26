# HPA Setup for GKE Lab
- **Metrics Server**: Verified running in `kube-system` (April 30, 2025).
- **HPA Status**: Enabled via GKE’s built-in Kubernetes API (`autoscaling/v2`).
- **Verification**:
  ```bash
  kubectl top pods -n <namespace>