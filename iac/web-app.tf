module "web_app_1" {
  source = "./modules/web-app"

  # Input Variables
  domain_name             = var.domain_name
  app_name                = var.app_name
  nextjs_export_directory = var.nextjs_export_directory
}


