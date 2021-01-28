terraform {
	required_version = ">=0.13"
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