################################################################################
# Setup central Verified Access trust provider
################################################################################
resource "aws_verifiedaccess_trust_provider" "this" {
  description              = "Central IAM trust provider"
  policy_reference_name    = "IAM"
  trust_provider_type      = "user"
  user_trust_provider_type = "iam-identity-center"
  tags = {
    Name = "Iam Identity Center"
  }
}

################################################################################
# Setup central Verified Access instance
################################################################################
resource "aws_verifiedaccess_instance" "this" {
  description = "Central AVA instance"
  tags = {
    Name = "Central AVA Instance"
  }
}

################################################################################
# Attach trust provider to Verified Access instance
################################################################################
resource "aws_verifiedaccess_instance_trust_provider_attachment" "this" {
  verifiedaccess_instance_id       = aws_verifiedaccess_instance.this.id
  verifiedaccess_trust_provider_id = aws_verifiedaccess_trust_provider.this.id
}

################################################################################
# Setup shared Verified Access group
################################################################################
resource "aws_verifiedaccess_group" "this" {
  verifiedaccess_instance_id = aws_verifiedaccess_instance.this.id
  policy_document            = <<-EOT
      permit(principal, action, resource)
      when {
        context.http_request.http_method != "INVALID_METHOD"
      };
      EOT
  tags = {
    Name = "Shared AVA Group"
  }

  depends_on = [
    aws_verifiedaccess_instance_trust_provider_attachment.this
  ]
}

################################################################################
# Share Verified Access group with another AWS account using AWS RAM
################################################################################
resource "aws_ram_resource_share" "this" {
  name                     = "shared-verified-access-group"
  allow_external_principals = true
  tags = {
    Name="Shared AVA group"
  }
}

resource "aws_ram_resource_association" "this" {
  resource_arn = aws_verifiedaccess_group.this.verifiedaccess_group_arn
  resource_share_arn = aws_ram_resource_share.this.arn
}

resource "aws_ram_principal_association" "this" {
  principal              = "0000000" # AWS account id
  resource_share_arn     = aws_ram_resource_share.this.arn
}