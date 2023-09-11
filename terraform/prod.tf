module "module_prod"{
source = "./modules"
prefix = "prod"
rgloc = "CentralIndia"
vnet-cidr = ["10.30.0.0/16"]
appsub-cidr = ["10.30.0.0/24"]
dbsub-cidr = ["10.30.1.0/24"]
}