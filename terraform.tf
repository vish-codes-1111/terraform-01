terraform {
  	required_providers {
    			aws = {
      			source  = "hashicorp/aws"
      			version = "~> 6.0"
    			}	
  		}
	backend "s3" {
		bucket = "remote-state-bucket-vish-1111" #our remote backend
		key = "terraform.tfstate" #the main file
		region = "us-east-1" 
		dynamodb_table = "state-table" #for state locking we need this 
	}
}	

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#always run terraform init after making changes in this file
