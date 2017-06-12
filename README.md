# cgp-dockstore

This tool builds an OpenStack image suitable for running tools and workflows registered
at Dockstore.org packer on openstack.

* [Requirements](#requirements)
* [Build Environment](#build-environment)
  * [OpenStack credentials (`my-tenant-openrc.sh`)](#openstack-credentials-my-tenant-openrcsh)
* [Building the base image](#building-the-base-image)
* [Customisation of the base image](#customisation-of-the-base-image)

## Requirements

* [Packer](https://www.packer.io/) - 0.11.0+
* [OpenStack Unified Client](https://docs.openstack.org/user-guide/common/cli-overview.html#unified-command-line-client) - 3.3.0+

## Build Environment

The build is 90% controlled by environment variables.

The relevant variables are held in:

* [`env/platform.env`](/env/platform.env)
  * Instance flavor for build, floating_ip_pool
* [`env/versions.env`](/env/versions.env)
  * Version numbers for dockstore and dependencies
  * See step 2 of [`Onboarding`](https://dockstore.org/onboarding)
* [`env/$UBUNTU_NAME/build.env`](/env/trusty/build.env)
  * Ubuntu version specific variables

#### OpenStack credentials (`my-tenant-openrc.sh`)

_Get this file from the Horizon interface_:

```
Tabs: Compute -> Access & Security -> API Access

Button: Download OpenStack RC File
```

![Horizon interface image](/images/HorizonRCfile.png)

## Building the base image

The base image is generated simply by executing the following:

```
scripts/pbuild.sh <trusty|xenial> <NETWORK_NAME> <SECURITY_GROUP> <XXX-openrc.sh>

e.g.
scripts/pbuild.sh trusty sellotape bubble-wrap my-tenant-openrc.sh
```

## Customisation of the base image

Other custom configuration can be applied on top of the base image by providing a `user_data` script.  An
example can be found [here](/examples/user_data.sh).

To run customise run:

```
scripts/customise.sh <NETWORK_NAME> <SECURITY_GROUP> <XXX-openrc.sh> \
 <CUSTOM_SCRIPT> <SOURCE_IMG_ID/NAME> <DEST_IMG_NAME>

e.g.

scripts/customise.sh sellotape bubble-wrap my-tenant-openrc.sh \
 my_custom.sh 'cgp-ds_trusty 2017-06-01 (1.0.0)' 'my-cgp-ds_trusty-1.0.0'
```
