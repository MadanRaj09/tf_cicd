module "module_uat"{
source = "./modules"
prefix = "uat"
rgloc = "CentralIndia"
vnet-cidr = ["10.20.0.0/16"]
appsub-cidr = ["10.20.0.0/24"]
dbsub-cidr = ["10.20.1.0/24"]
}