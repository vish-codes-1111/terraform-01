variable "aws_instance_type" {
    default = "t2.micro"
    type = string
}

variable "aws_instance_ami" {
    default = "ami-0b6d9d3d33ba97d99"
    type = string
}

variable "aws_instance_storage_size" {
    default = 10
    type = number
  
}
