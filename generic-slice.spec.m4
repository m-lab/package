#
# $Id:$
#
%define url $URL:$

%define name SLICE
%define version VERSION
%define taglevel TAG
ifdef(`DATE',
%define date DATE
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
Requires: slicebase

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
include(SLICEinstall)
dnl syscmd(`./rpmlist.sh list 'SLICE` install')

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
include(SLICEfiles)
dnl syscmd(`./rpmlist.sh list 'SLICE` files')

%pre
if test -f /etc/mlab/slice.installed ; then
    # NOTE: if the file exists, then %post was run at some time in the past.
    #       from an earlier version of this package.  which means this is an 
    #       update, which means we should shutdown the slice and recreate it.
    # TODO: stop experiment with slicectrl
    # TODO: make sure slice-update waits until the data collection pipeline is done
    /usr/bin/slice-update
fi

%post
# NOTE: leave a bread-crumb to indicate that the package was installed.
touch /etc/mlab/slice.installed

%preun
chkconfig --del slicectrl
service slicectrl stop

%postun

%changelog
* Fri Mar 08 2013 Stephen Soltesz <soltesz@opentechinstitute.org> slicebase-0.2-1
- adds call to initialize, with many return status checks through-out
