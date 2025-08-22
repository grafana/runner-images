packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "1.4.5"
    }
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}
