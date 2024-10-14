resource "aws_cognito_user_pool" "product_users" {
  name = "cloud-user-pool"

  email_verification_subject = "Your Verification Code"
  email_verification_message = "Please use the following code: {####}"
  alias_attributes           = ["email"]
  auto_verified_attributes   = ["email"]

  password_policy {
    minimum_length    = 6
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  username_configuration {
    case_sensitive = false
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 7
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "name"
    required                 = true

    string_attribute_constraints {
      min_length = 3
      max_length = 256
    }
  }
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id = aws_cognito_user_pool.product_users.id
  provider_name = "Google"

  provider_details = {
    client_id     = var.google_auth_client_id
    client_secret = var.google_auth_client_secret
    authorize_scopes = "profile email openid"
  }

  provider_type = "Google"
  attribute_mapping = {
    email     = "email"
    name      = "name"
    username  = "sub"
  }
}

resource "aws_cognito_user_pool_client" "product_users" {
  name         = "client"
  user_pool_id = aws_cognito_user_pool.product_users.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  prevent_user_existence_errors = "ENABLED"

  allowed_oauth_flows       = ["code"]
  allowed_oauth_scopes      = ["email", "openid"]
  allowed_oauth_flows_user_pool_client = true

  #callback_urls = [module.web_app_1.bucket_url]
  callback_urls = ["https://google.com"]


  supported_identity_providers = ["COGNITO", "Google"]
  depends_on = [aws_cognito_identity_provider.google]
}


resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain      = "my-user-pool-domain-cloud" 
  user_pool_id = aws_cognito_user_pool.product_users.id
}
