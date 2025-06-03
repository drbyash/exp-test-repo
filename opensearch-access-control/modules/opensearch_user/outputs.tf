output "user_names" {
  value = keys(opensearch_user.users)
}