terraform {
	required_version = ">=0.14.4"
}

provider "azurerm" {
	features {}
}

provider "helm" {
	features {}
}

provider "null" {
    features {}  
}