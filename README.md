# cgp-dockstore

This describes the build process used to generate our docker images for use with dockstore.

## Build Environment

The build is 90% controlled by environment variables.

The relevant variables are held in:

* [`env/shared.env`](env/shared.env) - core variables
* [`env/$UBUNTU_NAME/build.env`](env/trusty/build.env) - Ubuntu specific variables (base image)

#### OpenStack credentials

__Get this file from the Horizon interface__:

```
Tabs: Compute -> Access & Security -> API Access

Button: Download OpenStack RC File
```

Set an environment variable of `OS_CRED_FILE` to point to this file.

## Other configuration

____INCOMPLETE____

__This will be handled by an additional build script which picks up the 'current' image and applies this on top.__

Other custom configuration can be applied on top of the base image by providing a `user_data` script.  An
example can be found [here](../examples/user_data.sh).
