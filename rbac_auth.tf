# EKS cluster auth config map is usually managed via kubectl, but we can
# prepare an example Kubernetes config for future use via Helm or kubectl.

# This file intentionally does not create aws-auth ConfigMap, as that
# should be managed by your platform team with least-privilege mappings.