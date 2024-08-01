variable "name" {
  default = "dev-elasticache-cluster"
}

variable "engine" {
  default = "redis"
}

variable "node_type" {
  default = "cache.t2.micro"
}

variable "num_nodes" {
  default = 1
}
