resource "random_string" "password" {
  count            = var.need_db
  length           = 16
  special          = true
  override_special = "/@\" "
}

resource "random_string" "dbpassword" {
  count            = var.need_db
  length           = 16
  special          = true
  override_special = "/@\" "
}
