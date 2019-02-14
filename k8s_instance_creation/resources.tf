resource "aws_key_pair" "default" {
  key_name = "local-key"
  public_key = "${file("${var.key_path}")}"
}

#Define k8s-master inside the public subnet
resource "aws_instance" "k8s-master" {
   ami = "${data.aws_ami.ubuntu.id}"
   instance_type = "t1.micro"
   count = 1
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.k8s-public-sg.id}"]
   associate_public_ip_address = true
   key_name = "local-key"

  tags {
    Name = "k8s-master"
  }
}

# Define k8s-slave inside the private subnet
resource "aws_instance" "k8s-slave" {
   ami  = "${data.aws_ami.ubuntu.id}"
   count = 2
   instance_type = "t1.micro"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.k8s-private-sg.id}"]
   key_name = "local-key"  

  tags {
    Name = "k8s-slave"
  }
}
