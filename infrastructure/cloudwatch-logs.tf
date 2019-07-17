resource "aws_cloudwatch_log_group" "ckan" {
  name = "/ecs/ckan"
}

resource "aws_cloudwatch_log_group" "solr" {
  name = "/ecs/solr"
}

resource "aws_cloudwatch_log_group" "datapusher" {
  name = "/ecs/datapusher"
}
