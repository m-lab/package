#
# $Id:$
#
%define url $URL:$

%define name RPMSLICE
%define version RPMVERSION
%define taglevel RPMTAG
ifdef(`RPMDATE',
%define date RPMDATE
)

%define releasetag %{taglevel}%{?date:.%{date}}

# Turn off the brp-python-bytecompile script
# NOTE: at run-time this directive rewrites the __os_install_post 
#       macro from /usr/lib/rpm/redhat/macros by stripping the python bytecompile
%global __os_install_post %(echo '%{__os_install_post}' | sed -e 's!/usr/lib[^[:space:]]*/brp-python-bytecompile[[:space:]].*$!!g')

Vendor: Measurement Lab
Packager: Measurement Lab <support@measurementlab.net>
Distribution: Measurement Lab 1.5
URL: %(echo %{url} | cut -d ' ' -f 2)

Summary: Base initscripts and functions for experiment packages.
Name: %{name}
Version: %{version}
Release: %{releasetag}
# this is for centos6 only, package names change for future distros.
Requires: cronie
Requires: crontabs
# Requires: yum-cron

License: Apache License
Group: System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch: i686

Source0: %{name}-%{version}.tar.bz2

%description
The slicebase provides configuration for crond and a custom initscript for
rsync that will work within the slicebase conventiosn for experimetns on
M-lab.

%prep
%setup

%build

%install
mkdir -p $RPM_BUILD_ROOT/opt/slice/

install -D -m 0644 slicebase/etc/mlab/slicectrl-functions  $RPM_BUILD_ROOT/etc/mlab/slicectrl-functions
install -D -m 0644 slicebase/etc/mlab/slice-functions      $RPM_BUILD_ROOT/etc/mlab/slice-functions
install -D -m 0644 slicebase/etc/mlab/rsyncd.conf.m4       $RPM_BUILD_ROOT/etc/mlab/rsyncd.conf.m4
install -D -m 0644 slicebase/etc/mlab/rsyncd.legacy        $RPM_BUILD_ROOT/etc/mlab/rsyncd.legacy 

install -D -m 0755 slicebase/init/post-init       $RPM_BUILD_ROOT/etc/mlab/init/post-init

install -D -m 0755 slicebase/etc/init.d/slicectrl $RPM_BUILD_ROOT/etc/init.d/slicectrl
install -D -m 0755 slicebase/etc/init.d/rsyncd    $RPM_BUILD_ROOT/etc/init.d/rsyncd

install -D -m 0755 slicebase/bin/slice-update     $RPM_BUILD_ROOT/usr/bin/slice-update
install -D -m 0755 slicebase/bin/slice-restart    $RPM_BUILD_ROOT/usr/bin/slice-restart
install -D -m 0755 slicebase/bin/slice-canary     $RPM_BUILD_ROOT/usr/bin/slice-canary

# NOTE: this is an m4 macro 
include(SLICEinstall)

%clean
rm -rf $RPM_BUILD_ROOT

%files
# NOTE: default permissions are user:'slicename' group:slices
# NOTE: this is the default for PlanetLab-based VMs.

%defattr(-,RPMSLICE,slices)
# NOTE: these are slicebase files.
/opt/slice
%attr(0644,root,root) /etc/mlab/slice-functions
%attr(0644,root,root) /etc/mlab/slicectrl-functions
%attr(0644,root,root) /etc/mlab/rsyncd.conf.m4
%attr(0644,root,root) /etc/mlab/rsyncd.legacy
%attr(0755,root,root) /etc/mlab/init/post-init
%attr(0755,root,root) /etc/init.d/slicectrl 
%attr(0755,root,root) /etc/init.d/rsyncd 
%attr(0755,root,root) /usr/bin/slice-update
%attr(0755,root,root) /usr/bin/slice-restart
%attr(0755,root,root) /usr/bin/slice-canary

# NOTE: this is an m4 macro to include extra files
include(SLICEfiles)

%pre
if test -f /etc/mlab/slice.installed ; then
    # NOTE: if the file exists, then %post was run at some time in the past.
    #       i.e. from an earlier version of this package.  which means this 
    #       is an update, which means we should shutdown the slice and recreate 
    #       it.
    /usr/bin/slice-update
    # NOTE: refuse to do anything else.
    exit -1
fi
# NOTE: check for slicename-as-user and slices-as-group
# NOTE: if not present, create them.
if ! grep -qE "^%{name}:" /etc/group ; then
    /usr/sbin/groupadd slices
fi
if ! id -u %{name} > /dev/null ; then
    /usr/sbin/adduser -g slices %{name}
fi


%post
# NOTE: run post-install script to enable services and setup 
#       environment-dependent settings.
if [ -x /etc/mlab/init/post-init ] ; then
    /etc/mlab/init/post-init
fi

# NOTE: leave a bread-crumb to indicate that the package was installed.
touch /etc/mlab/slice.installed

# NOTE: enable yum-cron, 'start' only creates a file 
# chkconfig --level 345  yum-cron on
# service yum-cron start

%preun
# NOTE: stop experiment with slicectrl
chkconfig --del rsyncd
service rsyncd stop
chkconfig --del slicectrl
service slicectrl stop

%postun

%changelog
* Fri Apr 24 2013 Stephen Soltesz <soltesz@opentechinstitute.org> slicebase-0.x.x
- merge slicebase within generic slice spec wrapper
