resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.aws_azs)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "nat_gw"
  }

  depends_on = [aws_subnet.public_subnet]
}
