default['vault']['client']['url'] = 'https://releases.hashicorp.com/vault/0.6.5/vault_0.6.5_linux_amd64.zip'
default['vault']['client']['checksum'] = 'c9d414a63e9c4716bc9270d46f0a458f0e9660fd576efb150aede98eec16e23e'
default['selfsigned_certificate']['destination'] = '/etc/ssl/certificate'
default['vault']['client']['pathdir'] = '/usr/local/sbin'

default['consul']['config']['server'] = true
default['consul']['config']['bootstrap'] = true

default['aws_access_key'] = ""
default['aws_secret_key'] = ""
