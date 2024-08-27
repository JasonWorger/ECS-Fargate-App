module "ecs" {
  source                  = "./ECS"
  vpc_id                  = "vpc-02052c2eb890946a4"
  cluster_name            = "demo-api-cluster"
  cluster_service_name    = "flask-api-service"
  cluster_service_task_name = "flask-api-task"
  vpc_id_subnet_list      = ["subnet-09468bbf67d04ff63", "subnet-090482e74ffb9dd3b"]
  execution_role_arn      = "arn:aws:iam::303981612052:role/ecsTaskExecutionRole"
  image_id                = "303981612052.dkr.ecr.eu-north-1.amazonaws.com/flaskdemo:latest"
}
#Using an ECS module as easier to manage and can be re-usable if used correctly.
##Could improve by adding an additional variables.tf on root where these values would be picked up than being hard coded within the module itself.