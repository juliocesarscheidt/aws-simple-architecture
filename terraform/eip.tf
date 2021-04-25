resource "aws_eip" "nat_eip" {
  count = length(var.aws_azs)
  vpc   = true
}
