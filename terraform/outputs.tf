output "load_balancer_dns" {
  description = "The URL to access your Golang API"
  value       = module.compute.alb_dns_name
}

output "cloudfront_url" {
  description = "The URL to access your React Frontend"
  value       = module.storage.cloudfront_domain
}

output "s3_bucket_name" {
  description = "The bucket where GitHub Actions will push the React build"
  value       = module.storage.frontend_bucket_name
}