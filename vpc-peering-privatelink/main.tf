# VPC peering vs PrivateLink, side by side. Validate-only: never applied to a real account.
# Cost note: peering is free except cross-AZ/region transfer; an interface endpoint is ~USD 0.01/h per AZ + data.
terraform {
  required_version = "~> 1.9"
  required_providers {
    aws = { source = "hashicorp/aws", version = "5.81.0" }
  }
}

provider "aws" {
  region                      = "eu-west-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "validate-only"
  secret_key                  = "validate-only"
}

resource "aws_vpc" "consumer" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc" "provider" {
  cidr_block = "10.2.0.0/16" # must not overlap with the consumer for peering
}

# Option 1: peering - full L3 reachability between the two CIDRs, needs routes on both sides.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.consumer.id
  peer_vpc_id = aws_vpc.provider.id
  auto_accept = true
}

resource "aws_route_table" "consumer" {
  vpc_id = aws_vpc.consumer.id
  route {
    cidr_block                = aws_vpc.provider.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
}

# Option 2: PrivateLink - consumer reaches ONE service, CIDRs may overlap.
resource "aws_subnet" "provider" {
  vpc_id     = aws_vpc.provider.id
  cidr_block = "10.2.1.0/24"
}

resource "aws_lb" "orders" {
  name               = "orders-nlb"
  load_balancer_type = "network"
  internal           = true
  subnets            = [aws_subnet.provider.id]
}

resource "aws_vpc_endpoint_service" "orders" {
  acceptance_required        = true
  network_load_balancer_arns = [aws_lb.orders.arn]
}

resource "aws_subnet" "consumer" {
  vpc_id     = aws_vpc.consumer.id
  cidr_block = "10.1.1.0/24"
}

resource "aws_vpc_endpoint" "orders" {
  vpc_id            = aws_vpc.consumer.id
  service_name      = aws_vpc_endpoint_service.orders.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.consumer.id]
}
