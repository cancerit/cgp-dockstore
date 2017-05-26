# cgp-dockstore

This describes the build process used to generate our docker images for use with dockstore.

## Build Environment

The build is 90% controlled by environment variables.

The relevant variables are held in:

* [`env/shared.env`](/env/platform.env)
  * Instance flavor for build, floating_ip_pool
* [`env/versions.env`](/env/versions.env)
  * Version numbers for dockstore and dependencies
  * See step 2 of [`Onboarding`](https://dockstore.org/onboarding)
* [`env/$UBUNTU_NAME/build.env`](/env/trusty/build.env)
  * Ubuntu version specific variables

## Building the base image

The base image is generated simply by executing the following:

```
scripts/pbuild.sh <trusty|xenial> <NETWORK_NAME> <SECURITY_GROUP> <XXX-openrc.sh>

e.g.
scripts/pbuild.sh trusty sellotape bubble-wrap my-tenant-openrc.sh
```

#### OpenStack credentials (`my-tenant-openrc.sh`)

_Get this file from the Horizon interface_:

```
Tabs: Compute -> Access & Security -> API Access

Button: Download OpenStack RC File
```

![Horizon interface image](/images/HorizonRCfile.png)

## Customisation of the base image

Other custom configuration can be applied on top of the base image by providing a `user_data` script.  An
example can be found [here](/examples/user_data.sh).

To run customise run:

```
scripts/customise.sh <CUSTOM_SCRIPT> <SOURCE_IMG_ID/NAME> <DEST_IMG_NAME>

e.g.

scripts/customise.sh my_custom.sh 'cgp-ds_trusty 2017-02-16 (0.1.1)' 'my-cgp-ds_trusty-0.1.1'
```
