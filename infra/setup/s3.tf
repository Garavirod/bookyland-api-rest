/* ######################
# S3 bucket artifact #
######################
resource "aws_s3_bucket" "s3_artifact" {
    bucket = "${var.application_name}-artifact-store-bkt"
}

resource "aws_s3_bucket_versioning" "artifact_versioning" {
  bucket = aws_s3_bucket.s3_artifact.id
  versioning_configuration {
    status = "Enabled"
  }
}
 */
