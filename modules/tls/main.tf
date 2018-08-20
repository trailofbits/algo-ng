# resource "null_resource" "TLS_main" {
#   provisioner "local-exec" {
#     command =<<EOT
#       mkdir -p ${var.algo_config}/pki/{ecparams,certs,crl,newcerts,private,reqs} &&
#       touch ${var.algo_config}/pki/{.rnd,private/.rnd,index.txt,index.txt.attr,serial}
# EOT
#   }
# }
