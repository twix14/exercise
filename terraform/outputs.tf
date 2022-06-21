# output set of credentials for created user

output "user_access_key_id" {
  value = aws_iam_access_key.user.id
}

output "user_secret_accesss_key" {
  value = aws_iam_access_key.user.secret
  sensitive = true
}