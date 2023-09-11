variable "rgloc" {
    type = string
    default = "CentralIndia"
}

variable "vnet-cidr" {
    type = list(string)
    default = [ "10.0.0.0/16" ]
}

variable "appsub-cidr" {
    type = list(string)
    default = [ "10.0.0.0/24" ]
}

variable "dbsub-cidr" {
    type = list(string)
    default = [ "10.0.1.0/24" ]
}

variable "prefix" {
    type = string
    default = "dev"
}