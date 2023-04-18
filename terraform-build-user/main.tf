module "iam_user" {
  source = "github.com/cisagov/ami-build-iam-user-tf-module"

  providers = {
    aws                       = aws
    aws.images-production-ami = aws.images-production-ami
    aws.images-staging-ami    = aws.images-staging-ami
    aws.images-production-ssm = aws.images-production-ssm
    aws.images-staging-ssm    = aws.images-staging-ssm
  }

  ssm_parameters = [
    "/vnc/password",
    "/vnc/ssh/ed25519_private_key",
    "/vnc/ssh/ed25519_public_key",
    "/vnc/username",
  ]
  user_name = "build-assessor-workbench-packer"
}

# Attach 3rd party S3 bucket read-only policy from
# cisagov/ansible-role-assessor-workbench to the production EC2AMICreate
# role
resource "aws_iam_role_policy_attachment" "thirdpartybucketread_assessorworkbench_production" {
  provider = aws.images-production-ami

  policy_arn = data.terraform_remote_state.ansible_role_assessor_workbench.outputs.production_policy.arn
  role       = module.iam_user.ec2amicreate_role_production.name
}

# Attach 3rd party S3 bucket read-only policy from
# cisagov/ansible-role-assessor-workbench to the staging EC2AMICreate role
resource "aws_iam_role_policy_attachment" "thirdpartybucketread_assessorworkbench_staging" {
  provider = aws.images-staging-ami

  policy_arn = data.terraform_remote_state.ansible_role_assessor_workbench.outputs.staging_policy.arn
  role       = module.iam_user.ec2amicreate_role_staging.name
}
