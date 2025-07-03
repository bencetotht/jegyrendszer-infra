# resource "dns_a_record_set" "www" {
#   zone = "local.bnbdevelopment.hu."
#   name = "www"
#   addresses = ["192.168.1.100"]
#   ttl = 60
# }

# resource "dns_txt_record_set" "example" {
#   zone = "local.bnbdevelopment.hu."
#   name = "example"
#   txt = ["v=spf1 +all"]
#   ttl = 60
# }

resource "dns_txt_record_set" "test" {
  zone = "local.bnbdevelopment.hu."
  name = "test"
  ttl  = 300
  txt = ["terraform-test"]
}