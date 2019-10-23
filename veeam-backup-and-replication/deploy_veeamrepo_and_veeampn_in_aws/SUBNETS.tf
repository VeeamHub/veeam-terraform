resource "aws_subnet" "External" {
  vpc_id = "${aws_vpc.terraformmain.id}"
  cidr_block = "${var.vpc-subnet-cidr}"
  tags {
        Name = "External"
  }
 availability_zone = "${data.aws_availability_zones.available.names[0]}"
}
resource "aws_route_table_association" "External" {
    subnet_id = "${aws_subnet.External.id}"
    route_table_id = "${aws_route_table.RouteTable.id}"
}
 