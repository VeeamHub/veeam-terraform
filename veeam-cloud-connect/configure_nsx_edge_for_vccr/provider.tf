provider "vcd" {
  user                 = "${var.vcd_user}"
  password             = "${var.vcd_pass}"
  org                  = "${var.vcd_org}"
  url                  = "${var.vcd_url}"
  vdc                  = "${var.vcd_vdc}"
  max_retry_timeout    = "${var.vcd_max_retry_timeout}"
}