variable "application_name" {
  description = "Application name for taging resources"
  default     = "bookyland"
  type        = string
}

variable "contact" {
  description = "Contact name for taggin resources"
  default     = "me@example.com"
}

variable "tf_state_bucket" {
  description = "Name of s3 bucket in AWS for storing TF state"
  default     = "devops-tf-state-bookyland"
}

variable "tf_state_lock_table" {
  description = "Name of Dynamo table for storing TF lock"
  default     = "devops-tf-lock-bookyland"
}

variable "prefix" {
  description = "Prefix for resources in AWS"
  default     = "bookyland"
}
// github
variable "github_user_name" {
  description = "Github Username"
  default = "Garavirod"
}

variable "github_repository_name" {
  description = "Github repository project"
  default = "bookyland-api-rest"
}

variable "github_oauthtoken" {
  description = "Github token for access into repo"
  sensitive = true
}
// Secrets db
variable "database_user_password" {
  description = "Database user password"
  sensitive = true
}

/* 
  According what I mentioned above about directories /deploy and /setup
  How could I deploy my infra (./deploy) into ECS by using codepipeline, codebuild and codedeploy (blue/green deployment)and terraform?
  When this needs to be deploy by using github actions manually (dispatch_wrokflow) either on prod or dev branch.


  My directories are as follow:
  /app
  /infra
  --/deploy
  --/setup
  --docker-compose.yaml (terraform into infra dir root)
  docker-compose.yaml (app FastAPI applciation)


  Docker compose file (terraform image into infra dir root):

  services:
  terraform:
    image: hashicorp/terraform:1.6.2
    volumes:
      - ./setup:/tf/setup
      - ./deploy:/tf/deploy
    working_dir: /tf
    environment: # AWS credentials are set via AWS vault on behalf
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
      - AWS_DEFUALT_REGION=us-east-1
      - TF_WORKSPACE=${TF_WORKSPACE}

  - Either /setup directory and /deploy directory are independtly terrafom projects
  - Either state and lock files for /setup directory and /deploy directory backend are managed by S3 and Dynamo
  - it is necessary to push the app image into ECR
  - for terrafom deploy infra stage could run the follow steps:

  cd infra/
  docker compose run --rm terraform -chdir=deploy/ init
  docker compose run --rm terraform -chdir=deploy/ workspace select -or-create $workspace
  docker compose run --rm terraform -chdir=deploy/ apply -auto-approve

  - The workspace needs to be defined if is pord branch or dev branch
  - There is an Mysql RDS defined in a terrafom file (databse.tf). and the prop "password" is set by "var.db_password"; This varibale is defined in varaibles.tf and it value needs to be obtain from Secret Manger during run time to set it
  - Use best practices
  - Stick around the free tier as much you can (No worry if is not posible at all)
 */
