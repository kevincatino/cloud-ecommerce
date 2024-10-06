output "www_bucket_id" {
  value = aws_s3_bucket.www.id
  description = "ID of www bucket"
}

output "root_bucket_id" {
  value = aws_s3_bucket.root.id
  description = "ID of root bucket"
}