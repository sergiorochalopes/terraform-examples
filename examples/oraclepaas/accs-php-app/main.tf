// Copyright (c) 2018, 2019, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.

variable user {}
variable password {}
variable domain {}
variable compute_endpoint {}
variable storage_endpoint {}

provider "oraclepaas" {
  version              = "> 1.3.0"
  user                 = "${var.user}"
  password             = "${var.password}"
  identity_domain      = "${var.domain}"
  application_endpoint = "https://apaas.us.oraclecloud.com"
}

provider "opc" {
  version          = "> 1.1.0"
  user             = "${var.user}"
  password         = "${var.password}"
  identity_domain  = "${var.domain}"
  storage_endpoint = "${var.storage_endpoint}"
}

data "archive_file" "example-php-app" {
  type        = "zip"
  source_dir  = "${path.module}/php-app/"
  output_path = "${path.module}/php-app.zip"
}

resource "opc_storage_container" "accs-apps" {
  name = "my-accs-apps"
}

resource "opc_storage_object" "example-php-app" {
  name         = "php-app.zip"
  container    = "${opc_storage_container.accs-apps.name}"
  file         = "${data.archive_file.example-php-app.output_path}"
  etag         = "${data.archive_file.example-php-app.output_md5}"
  content_type = "application/zip;charset=UTF-8"
}

resource "oraclepaas_application_container" "example-php-app" {
  name              = "PhpWebApp"
  runtime           = "php"
  archive_url       = "${opc_storage_container.accs-apps.name}/${opc_storage_object.example-php-app.name}"
  subscription_type = "HOURLY"

  deployment {
    memory    = "1G"
    instances = 1
  }
}

output "web_url" {
  value = "${oraclepaas_application_container.example-php-app.web_url}"
}
