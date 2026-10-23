locals {
  is_prod = lower(var.environment) == "prod"

  common_tags = merge(
    {
      ManagedBy   = "ace"
      Environment = var.environment
      Project     = var.project_id
    },
    var.tags
  )

  # For prod, prefer 3 AZs; for dev, 2 AZs is sufficient
  desired_az_count = local.is_prod ? 3 : 2
}