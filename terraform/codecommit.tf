resource "aws_codecommit_repository" "password-store" {
  provider = "aws.codecommit"
  repository_name = "${var.team_name}-password-store"
  description = "Git for the ${team_name}'s password store"
}

resource "aws_iam_user" "password-store-git" {
  name = "${var.env}-git-pass"
}

resource "aws_iam_user_ssh_key" "git" {
  username = "${aws_iam_user.git.name}"
  encoding = "PEM"
  public_key = "${var.git_rsa_id_pub}"
}
