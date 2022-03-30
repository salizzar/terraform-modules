variable "aws_ecs_cluster" {
  type = object({
    name = string
    tags = map(string)
  })
}
