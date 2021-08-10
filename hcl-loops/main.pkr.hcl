# Introduced in Packer v1.7
#packer {
#    required_plugins {
#    }
#}

locals {
  image_gallery = {
    name = "my-images-ig"
    rg   = "my-gallery-rg"
  }

  # Define all the images in a locals block, and keep it as clean
  # as possible by using lookups within the source object below
  # to set standard values.
  images = {
    standard_image = {
      source = "azurerm.main"
      shared_image_gallery_destination = {
        image_version = "2.3"
      }
    }
    terraform = {
      source = "azurerm.main"
      shared_image_gallery_destination = {
        image_version = "1.0"
      }
    }
    terraform_beta = {
      source = "azurerm.main"
      shared_image_gallery_destination = {
        image_version = "1.1"
      }
    }
    dbserver = {
      source = "azurerm.dbserver"
      shared_image_gallery_destination = {
        image_version = "1.0"
      }
    }
  }
}

# Only make new sources when an image will require unique
# hardware differences. In general this would be a very small
# list, except in very large deployments.
source "azurerm" "main" {
  image_publisher                   = ""
  image_offer                       = ""
  image_sku                         = ""
  managed_image_name                = ""
  managed_image_resource_group_name = ""
}

source "azurerm" "dbserver" {
  image_publisher                   = ""
  image_offer                       = ""
  image_sku                         = ""
  managed_image_name                = ""
  managed_image_resource_group_name = ""
  disk_additional_size              = [1024,256]
}

# Use one build block and one dynamic source block to build
# every image needed.
build {
  dynamic "source" {
    for_each = local.images
    labels   = [source.value.source]

    content {
      name = source.key
      shared_image_gallery_destination {
        resource_group_name = lookup(source.value.shared_image_gallery_destination, "resource_group_name", local.image_gallery.rg)
        gallery_name        = lookup(source.value.shared_image_gallery_destination, "gallery_name", local.image_gallery.name)
        image_name          = source.value.shared_image_gallery_destination.image_name
        image_version       = "${source.value.shared_image_gallery_destination.image_version}.${var.BUILD_ID}"
      }
    }
  }
  
  # Very few variables are available to a provisioner
  # https://www.packer.io/docs/templates/hcl_templates/contextual-variables
  # Passing the source.name variable through as an Ansible tag allows us to
  # use one provisioner definition, and rely on Ansible tags for all the 
  # unique changes to builds. You could use overrides here too for very unique
  # differences between images.
  changes
  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    command       = "ansible-playbook --var 'BUILD_ID=$BUILD_ID' ./playbook.yml"
    extra_arguments = [
      "--tags",
      source.name
    ]
  }
}
