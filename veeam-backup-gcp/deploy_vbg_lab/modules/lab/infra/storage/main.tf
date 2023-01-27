### Storage bucket module - creates Google storage bucket  ###

resource "google_storage_bucket" "repo" {
  name = "${var.name_prefix}-${var.user_id}"
  location      = "${var.location}"
  storage_class = "${var.storage_class}"
  force_destroy = var.force_destroy
  public_access_prevention = var.public_access_prevention
}