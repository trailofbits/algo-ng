data "github_release" "algo" {
  repository  = "algo-ng-chef"
  owner       = "jackivanov"
  retrieve_by = "latest"
}

data "http" "algo_assets_url" {
  url = data.github_release.algo.asserts_url
  request_headers = {
    Accept = "application/json"
  }
}

data "template_file" "shell" {
  template = file("${path.module}/files/user-data.sh")
}

data "template_cloudinit_config" "cloud_config" {
  gzip          = var.gzip
  base64_encode = var.base64_encode

  part {
    filename     = "algo.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/files/user-data.yml",
      {
        algo_release_url = jsondecode(data.http.algo_assets_url.body).0.browser_download_url
      }
    )
  }
}

output "cloud_config" {
  value = data.template_cloudinit_config.cloud_config.rendered
}
