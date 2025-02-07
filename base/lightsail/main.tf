module "cloud" {
  source      = "../../modules/clouds/lightsail/"
  algo_config = local.config
  deploy_id   = local.module_init.deploy_id
  ssh_key     = local.module_init.ssh_key
  user_data   = local.module_init.user_data

  providers = {
    aws = aws.lightsail
  }
}

provider "aws" {
  alias  = "lightsail"
  region = replace(local.config.clouds.lightsail.availability_zone, "/[a-z]$/", "")
}

variable "state_passphrase" {
  description = <<-EOT
    Passphrase used to encrypt sensitive data. Must be at least 16 characters long.
    You must securely record or remember this passphrase, as it is required for future server changes, such as updating users or destroying the server.
  EOT

  sensitive = true
  type      = string
}

terraform {
  encryption {
    key_provider "pbkdf2" "default" {
      passphrase    = var.state_passphrase
      key_length    = 32
      salt_length   = 32
      hash_function = "sha512"
      iterations    = 600000
    }

    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.default
    }

    state {
      method   = method.aes_gcm.default
      enforced = true
    }

    plan {
      method   = method.aes_gcm.default
      enforced = true
    }
  }
}
