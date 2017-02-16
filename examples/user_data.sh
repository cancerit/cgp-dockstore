#/bin/bash

set -uxe

echo "
This is an example user data file for OpenStack.
You should add any customisation here.

Standard examples are included (but redacted) below.
"

exit 0

## add sanger security certificates
sudo mkdir -p /usr/share/ca-certificates/sanger.ac.uk
sudo bash -c 'echo "-----BEGIN CERTIFICATE-----
M...
-----END CERTIFICATE-----" > /usr/share/ca-certificates/sanger.ac.uk/Genome_Research_Ltd_Certificate_Authority-cert.pem'

sudo bash -c 'echo "sanger.ac.uk/Genome_Research_Ltd_Certificate_Authority-cert.pem" >> /etc/ca-certificates.conf'
sudo update-ca-certificates -v

### MY S3 CFG
sudo -u ubuntu bash -c 'echo "[default]
access_key = ...
encrypt = False
host_base = cog.sanger.ac.uk
host_bucket = %(bucket)s.cog.sanger.ac.uk
progress_meter = False
secret_key = ...
use_https = True
" > ~/.s3cfg'
