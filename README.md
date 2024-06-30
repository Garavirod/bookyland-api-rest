## Api Rest Fast API Docker compose | AWS | Terraform

Create an image

`docker build -t <your tag> ./<your context>`

List images

`docker image ls`

Terraffrom comands:

[Terraform aws provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

Terrafrom is a intermediary between terrafrom and cloud api provider

`alias tf="terraform"`

`tf fmt # Useful for giving formatt to all the files in the directory`

`tf apply # with confirmation`

tf apply -auto-approve # Automaticaly confirm changes for deploying

tf destroy -aout-approve

tf plan # to verify if cloud does not match with terrafom local
