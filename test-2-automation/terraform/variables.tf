variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "public_ssh_key" {
  description = "Public SSH key for VMs"
  type        = string
  sensitive   = true
}

variable "my_ip" {
  description = "Your public IP address (for SSH restriction)"
  type        = string
  default     = "0.0.0.0/0"   # replace with your actual IP after running `curl ifconfig.me`
}
