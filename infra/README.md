### **CodeBuild Definition**

**1. `aws_codebuild_project.deploy_dev`:**

* **Purpose**: Defines a CodeBuild project named `${var.application_name}-codebuild` for the `dev` environment.
* **Artifacts**:
  * `type = "CODEPIPELINE"`: The build artifacts (output) from this project are sent to CodePipeline. The artifacts produced by the CodeBuild project will be used in subsequent stages of the pipeline.
* **Environment**:
  * **Compute Type**: Specifies the size of the build environment.
  * **Image**: Uses a standard AWS CodeBuild Docker image for the build environment.
  * **Privileged Mode**: Required for Docker-in-Docker operations, which is necessary for building and pushing Docker images.
  * **Environment Variables**: Includes various environment variables like Docker Hub credentials, ECR URI, AWS region, SSM parameters, and more.
* **Source**:
  * **Type**: `CODEPIPELINE`, meaning CodeBuild gets its source code from CodePipeline, which is defined in the `Source_Dev` stage of the pipeline.
  * **Buildspec**: Specifies the path to the `buildspec.yml` file that contains the build commands and steps.

### **CodePipeline Definition**

**2. `aws_codepipeline.deploy`:**

* **Purpose**: Defines a CodePipeline for deploying the application. It orchestrates the CI/CD process, coordinating the various stages of source retrieval, build, and deployment.
* **Stages**:
  * **Source\_Dev**:
    * **Action**: Fetches source code from GitHub using a CodeStar connection.
    * **Output Artifacts**: Defines `source_output_dev`, which is passed to the next stage (Build\_Dev).
  * **Build\_Dev**:
    * **Action**: Uses the CodeBuild project (`aws_codebuild_project.deploy_dev`) to build and package the application.
    * **Input Artifacts**: Takes `source_output_dev` from the Source\_Dev stage.
    * **Output Artifacts**: Defines `build_output_dev`, which could be used if there were additional stages (e.g., deployment).
* **Artifact Store**:
  * **Type**: `S3`
  * **Location**: Specifies the S3 bucket (`aws_s3_bucket.s3_artifact.bucket`) where pipeline artifacts are stored. This bucket holds intermediate build artifacts and deployment files.

### **Buildspec File**

**3. `buildspec.yml`:**

The buildspec file defines the build process in CodeBuild. It is divided into several phases:

* **Install**:
  * **Commands**: Installs dependencies like `jq`, `wget`, `unzip`, and Terraform. This phase ensures the build environment is ready with necessary tools.
* **Pre\_build**:
  * **Commands**:
    * Logs into Docker Hub and Amazon ECR using credentials retrieved from AWS SSM Parameter Store.
    * Retrieves SSM parameters required for the build and deployment.
* **Build**:
  * **Commands**:
    * Builds a Docker image from the source code using Docker and tags it with the commit SHA and `latest`.
* **Post\_build**:
  * **Commands**:
    * Pushes the Docker images to ECR.
    * Initializes and applies Terraform configurations from the `deploy` directory to set up the infrastructure.
* **Cache**:
  * **Paths**: Caches Docker layers to speed up subsequent builds by avoiding repeated downloads of base images and layers.

### **S3 Artifact Bucket**

**Purpose and Use**:

* The S3 artifact bucket (`aws_s3_bucket.s3_artifact.bucket`) is used to store pipeline artifacts. Artifacts can include build outputs, deployment files, or other intermediate files that need to be passed between different stages of the pipeline or preserved for later use.
* **Interaction**:
  * **CodePipeline**: Stores the artifacts produced by each stage. For instance, after the build stage, the build artifacts are saved in this bucket.
  * **CodeBuild**: Specifies this bucket as the artifact store location where CodePipeline retrieves and stores artifacts.

### **Summary**

1. **CodePipeline** manages the CI/CD process by orchestrating different stages.
2. **CodeBuild** is used within the pipeline to build Docker images and deploy Terraform configurations.
3. **S3 Artifact Bucket** is used to store and transfer build and deployment artifacts between different stages of the pipeline.

The integration of these components ensures that code changes are automatically built, tested, and deployed, streamlining the deployment process and maintaining a consistent deployment workflow.

### **Artifacts Storage in CodePipeline**

1. **Source Stage**:
   * **Source Artifacts**: When you configure the Source stage (e.g., from GitHub), the source code is pulled and stored as an artifact named `source_output_dev` (as specified in the pipeline configuration).
   * **Content**: This typically includes the entire source code repository or the specific branch of code that you’re deploying. It might also include configuration files and scripts necessary for the build process.
2. **Build Stage**:
   * **Input Artifacts**: The input artifact for this stage is `source_output_dev`, which comes from the Source stage. This artifact contains the source code and related files needed for the build.
   * **Build Artifacts**: After CodeBuild processes the source code, it generates new artifacts. In this case, the `buildspec.yml` file specifies that Docker images are built and pushed to Amazon ECR, but the output artifact name (`build_output_dev`) might not be used directly in this example.
3. **Artifact Store**:
   * **S3 Bucket**: The S3 bucket configured in CodePipeline (`aws_s3_bucket.s3_artifact.bucket`) serves as a centralized location for storing these artifacts. When the pipeline runs, it stores the output of each stage (if configured to do so) in this bucket.
   * **Purpose**: This bucket helps in persisting and transferring build and deployment artifacts between stages. For example, the source code artifact retrieved from GitHub is stored here temporarily before being used in the build stage.

### **In Summary**

* **Source Artifacts**: Includes your GitHub source code or files from the repository.
* **Build Artifacts**: In this case, these would be the Docker images pushed to ECR, but typically, they could include any output files from the build process.
* **S3 Artifact Bucket**: Used to temporarily store these artifacts between pipeline stages.

So, the S3 bucket does indeed store artifacts related to your pipeline stages, including your source code initially, and potentially build outputs if they are configured to be stored.

### Destroy terraform infra manually.

An approach is to use a **manual trigger on a specific branch** in your GitHub (or another repository). You can create a separate branch (like `destroy-manual-trigger`) that you rarely or never update, ensuring the pipeline is triggered only when you manually push something to it. Then, just initiate the destruction process manually by pushing an empty commit to this branch.

This still uses a real source, but you control when it triggers by pushing empty commits:

```
git commit --allow-empty -m "Trigger destroy pipeline"
git push origin destroy-manual-trigger
```
