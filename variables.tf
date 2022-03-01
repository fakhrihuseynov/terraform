variable "server_name" {
  description = "Name for the WebServer"
  type = string
  default = "demo"
}
variable "server_size" {
  description = "Server size for the WebServer"
  type = string
  default = "t3.micro"
}