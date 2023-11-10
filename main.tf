# setup terraform required providers, needed to say Im using AWS
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# a resource for a budget, want to not spend much.
resource "aws_budgets_budget" "monthly_budget" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = "20.00"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2023-11-01_00:01"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.email_address]
  }
}