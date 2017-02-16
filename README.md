# cgp-dockstore

This describes the build process used to generate our docker images for use with dockstore.

## Setup Build Environment

The build is 90% controlled by environment variables.

The relevant variables are held in [`cgpbox_env.sh`](cgpbox_env.sh), please take special note of the `source`'ed elements as you will need to ensure these are in place in your home directory.

#### ~/ostack_cred.sh

__Get this file from the Horizon interface__:

```
Tabs: Compute -> Access & Security -> API Access

Button: Download OpenStack RC File
```
