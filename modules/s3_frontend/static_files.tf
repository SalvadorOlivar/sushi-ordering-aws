locals {
  static_files = fileset("${path.module}/static", "**")
}

resource "aws_s3_object" "static_files" {
  for_each = { for file in local.static_files : file => file }
  bucket = aws_s3_bucket.frontend.id
  key    = each.key
  source = "${path.module}/static/${each.key}"
  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript"
  }, split(".", each.key)[length(split(".", each.key))-1], "application/octet-stream")
  source_hash = filemd5("${path.module}/static/${each.key}")
}
