#!/usr/bin/env bash

### Install lsb_release on RHEL 9
subscription-manager repos \
    --enable codeready-builder-for-rhel-9-"$(arch)"-rpms
dnf install \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf update --yes
dnf install --yes lsb_release


dnf install dnf-plugins-core
dnf config-manager --set-enabled crb


### Enable the required repositories for RHEL 9
subscription-manager repos \
   --enable=rhel-9-for-x86_64-baseos-rpms \
   --enable=rhel-9-for-x86_64-appstream-rpms \
   --enable=rhel-9-for-x86_64-supplementary-rpms

### RHEL 9
dnf install https://www.rdoproject.org/repos/rdo-release.el9.rpm
dnf remove https://www.rdoproject.org/repos/rdo-release.el9.rpm



subscription-manager refresh
dnf clean all
dnf repolist


dnf update -y
Updating Subscription Management repositories.
Last metadata expiration check: 0:00:33 ago on Sun 26 May 2024 10:28:13 AM PDT.
Error:
 Problem: package ansible-1:7.7.0-1.el9.noarch from @System requires python3.9dist(ansible-core) >= 2.14.7, but none of the providers can be installed
  - package openstack-ansible-core-2.14.2-4.1.el9s.x86_64 from openstack-caracal obsoletes ansible-core provided by ansible-core-1:2.14.14-1.el9.x86_64 from @System
  - package openstack-ansible-core-2.14.2-4.1.el9s.x86_64 from openstack-caracal obsoletes ansible-core provided by ansible-core-1:2.14.9-1.el9.x86_64 from rhel-9-for-x86_64-appstream-rpms
  - package openstack-ansible-core-2.14.2-4.1.el9s.x86_64 from openstack-caracal obsoletes ansible-core provided by ansible-core-1:2.14.14-1.el9.x86_64 from rhel-9-for-x86_64-appstream-rpms
  - cannot install the best update candidate for package ansible-core-1:2.14.14-1.el9.x86_64
  - cannot install the best update candidate for package ansible-1:7.7.0-1.el9.noarch
(try to add '--skip-broken' to skip uninstallable packages or '--nobest' to use not only best candidate packages)
