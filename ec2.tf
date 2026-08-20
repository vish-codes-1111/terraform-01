#key pair
resource aws_key_pair my_key{
	key_name = "terra-key"
	public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPj4RJCNVzJDq/V8Jg3DycarlO1YZJTO8S31zbk8V+wG tomcat@DESKTOP-G87EHA6"
}

#VPC & Security Group
resource aws_default_vpc default {
	}

resource aws_security_group the_security {
	name = "automate-sec-group" 
	description = "This will add an Terraform generated Security Group"
	vpc_id = aws_default_vpc.default.id # this is called Interpolation  
	
	#inbound rules
	ingress {
		from_port = 22
		to_port = 22		
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"] 
		}
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		description = "HTTP open" #totally optional
		}
	
	#outbound rules
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"	#basically all the ports
		cidr_blocks = ["0.0.0.0/0"]
		}

	tags = {
		Name = "automate-sec-group"
		}
	
	}

#EC2
resource "aws_instance" "my-ec2" {
	for_each = tomap({
		ec2_micro = "t2.micro"
		ec2_medium = "t2.small"
		ec2_medium = "t2.large"
	})
	key_name = aws_key_pair.my_key.key_name
	security_groups = [aws_security_group.the_security.name]
	instance_type = each.value
	ami = var.aws_instance_ami	#amazon machine image

	user_data = file("install_nginx.sh") #this is a bash script that will run on the instance at launch time
	
	root_block_device {
		volume_size = var.aws_instance_storage_size
		volume_type = "gp3"
	}
	tags = {
		Name = each.key
	}
}
