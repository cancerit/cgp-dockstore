#/bin/bash

set -uxe

echo "
This is an example user data file for OpenStack.
You should add any customisation here.

Standard examples are included (but redacted) below.
"

exit 0

## add security certificates
sudo mkdir -p /usr/share/ca-certificates/somedomain.ac.uk
sudo bash -c 'echo "-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----" > /usr/share/ca-certificates/somedomain.ac.uk/SOMEGROUP_Certificate_Authority-cert.pem'

sudo bash -c 'echo "somedomain.ac.uk/SOMEGROUP_Certificate_Authority-cert.pem" >> /etc/ca-certificates.conf'
sudo update-ca-certificates -v

### S3CMD CFG
sudo -u ubuntu bash -c 'echo "[default]
access_key = ...
encrypt = False
host_base = ...
host_bucket = ...
progress_meter = False
secret_key = ...
use_https = True
" > ~/.s3cfg'

sudo -u ubuntu mkdir -p /home/ubuntu/.dockstore /home/ubuntu/.aws

### AWS version of S3 config, saves passing to dockstore via env
sudo -uubuntu bash -c 'echo "[default]
aws_access_key_id=...
aws_secret_access_key=...
" > ~/.aws/credentials

### MY dockstore credentials:
sudo -u ubuntu bash -c 'echo "token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
server-url: https://dockstore.org:8443
" > /home/ubuntu/.dockstore/config'
