module "module_dev"{
source = "./modules"
prefix = "dev"
rgloc = "CentralIndia"
vnet-cidr = ["10.0.0.0/16"]
appsub-cidr = ["10.0.0.0/24"]
dbsub-cidr = ["10.0.1.0/24"]
}