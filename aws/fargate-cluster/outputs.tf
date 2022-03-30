output "cluster-id" {
  value = "${aws_ecs_cluster.main.id}"
}

output "cluster-arn" {
  value = "${aws_ecs_cluster.main.arn}"
}

output "cluster-name" {
  value = "${aws_ecs_cluster.main.name}"
}
