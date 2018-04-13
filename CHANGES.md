# CHANGES

## 2.1.0

* Migrates to Pike and v2 identity API
* Upgrades Dockstore to 1.4.1
* Upgrades to dockstore-s3cmd-plugin 0.8

## 2.0.2

Update to Dockstore 1.3.6

## 2.0.1

Push the cache settings into ~/.dockstore/config to save looking it up.

## 2.0.0

* Now supports both Ubuntu and Alpine linux builds
  * Ubuntu is currently set to Xenial (~2.2GB image)
  * Alpine is 3.7-virtual (~700MB image)
* Dockstore CLI 1.3.3
* Dockstore s3cmd plugin 0.0.7 (files >150GB now supported)

## 1.3.0

* Now able to specify docker version
* Default `env/versions.env` updated (also adds locked version for `ruaml.yaml`)
* Fixed Trusty build now docker-ce requires additional packages for it...
* _Trusty_ support __will be dropped__ at next release

## 1.2.3

* Update dockstore version to 1.2.5
* Fix #3 s3cmd plugin updated to 0.0.6

## 1.2.2

Added missing config to ~/.dockstore/config to allow use of s3cmd plugin "out-of-the-box".

## 1.2.1

* Corrects the URL embedded in created image description
* Fixes #2, when using the customisation script.

## 1.2.0

* First release directly to GitHub
* Mostly documentation

## 1.1.0

* dockstore 1.2.3 - new output features
* Better docs

## 1.0.1

* Fixes some issues with absent env variables

## 1.0.0

* dockstore 1.1.5
* Updates to build scripts adding more params to reduce Sanger specific entries in committed files

## 0.1.1

* dockstore 1.1.2 and related dependencies
