
variable "ami_id" {
  type        = string
  description = "Which image to use"
  validation {
    condition     = length(var.ami_id) >= 21 && substr(var.ami_id, 0, 4) == "ami-"
    error_message = "The AMI ids need to start with ami- and is 21 characters."
  }
}

variable "instance_type" {
  type        = string
  description = "THe instance type"
}

variable "key_pair_name" {
  type        = string
  description = "Name of key pair to use for instance."
}

variable "vpc_id" {
  description = "The id for the vpc"
  type        = string
  validation {
    condition     = length(var.vpc_id) > 12 && substr(var.vpc_id, 0, 4) == "vpc-"
    error_message = "The AMI ids need to start with ami- and is at least 12 characters."
  }
}

variable "common_tags" {
  type        = map(any)
  description = "Implements the common_tags scheme"
}

variable "allowlist" {
  description = "The CIDRs that can have access to the instance"
  type        = list(any)
  default     = ["10.0.0.0/16"]
}

variable "private_subnets" {
  type = list(any)
  default = null
}

variable "public_subnets" {
  type = list(any)
  default = null
}

variable "alb_allowlist" {
  type        = list(any)
  description = "The allow list"
  default     = ["0.0.0.0/0"]
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "alb_internal" {
  type    = bool
  default = true
}


variable "alb_acm_arn" {
  type        = string
  description = "ALB ACM ARN"
  default      = null
}
