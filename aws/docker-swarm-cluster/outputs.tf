output "sg-swarm-id" {
  value = "${aws_security_group.swarm.id}"
}

output "mgr-instance-ids" {
  value = ["${aws_instance.mgr.*.id}"]
}

output "wkr-instance-ids" {
  value = ["${aws_instance.wkr.*.id}"]
}
