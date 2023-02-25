# Standard tagging
module "naming_conventions" {
  source               = "git::git@ssh.dev.azure.com:v3/orionadvisor/ITOC/tf-module-tagging?ref=v1.0.8"
  application          = var.application
  environment          = var.environment
  managing_cost_center = var.managing_cost_center
  map_migrated         = var.map_migrated
  product              = var.product
  region               = var.region
  team                 = var.team
  tf_backend           = local.tf_backend
  tf_repo              = var.tf_repo
}

# Billing
module "lt" {
  source               = "git::git@ssh.dev.azure.com:v3/orionadvisor/ITOC/tf-module-launch-template?ref=v1.0.2"
  application_service  = var.application
  environment          = var.environment
  iam_instance_profile = data.aws_iam_instance_profile.profile.name
  image_id             = var.ami_id
  instance_type        = var.instance_type
  region               = var.region
  resource_tags        = local.tags
  security_group_ids   = [data.aws_security_group.sg.id]
  user_data            = local.user_data
}

module "asg" {
  source                  = "git::git@ssh.dev.azure.com:v3/orionadvisor/ITOC/tf-module-autoscaling-group?ref=v1.0.3"
  application_service     = var.application
  desired_capacity        = var.desired_capacity
  environment             = var.environment
  force_delete            = var.force_delete
  launch_template_id      = module.lt.launch_template.id
  launch_template_version = module.lt.launch_template.latest_version
  max_size                = var.max_size
  min_size                = var.min_size
  region                  = var.region
  subnets_ids             = data.aws_subnet_ids.private.ids
  tags                    = merge(local.tags, var.tags)
  instance_refresh = {
    strategy = var.instance_refresh_strategy
  }
}