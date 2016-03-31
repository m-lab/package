M-Lab Packaging Support
=======================

This repository contains scripts to help build packages for experiments
deployed to M-Lab.

By convention new experiments receive a repository in the m-lab
organization on github.com.  Ownership of this repository is shared between
M-Lab operators and the researcher writing the experiment.

    https://github.com/m-lab

If a new experiment is called 'example', then the repository would be named 

    https://github.com/m-lab/example-support

The example-support repository would contain a submodule references to this repository.

    git clone https://github.com/m-lab/example-support
    git submodule add https://github.com/m-lab/package
    git commit -a -m "add M-Lab 'package' as submodule of example-support"
    git push

Tagging 
-------

Packages are named using git tags.

A new tag can be added using this command:

    ./package/slicetag.sh set <version>

The tag will be set locally and pushed remotely.  The tag will be of the form:

    <version>-<count>.mlab

The string <version> can be any sequence of [a-zA-Z0-9.].  While other strings
may be possible, these characters will guarantee compatibility with package
naming conventions and version conventions based on those names.

An example:

    iupui_ndt-3.6.5.1.pre2-12.mlab.i686.rpm
    <slicename>-<slicetag>.<arch>.rpm

In the example above, "3.6.5.1.pre2" is the tool version.  The rest is a result
of M-Lab support and the build environment.

If M-Lab is managing your package deployments, then the slicetag should be
communicated to M-Lab ops team so that they can reference the new tag in the
master slice-tags.list.  

Building
--------

The experiment support repository should include at least one shell script:

    init/prepare.sh

Please see the templates and comments in [prepare.sh][1].

Once this is in place, you can build your package using:
    
    ./pacakge/slicebuild.sh <slicename>

By default, the output of the build will be saved to these directories:

    /home/<slicename>
    $PWD/build

The script `slicebuild.sh` uses default values for some directory locations.
However you can override them using environment variable.  Specifically:
    
    SOURCE_DIR -- the slice suport directory, default $PWD
    BUILD_DIR -- the output of prepare.sh, default /home/<slicename>
    RPMBUILD -- the output of slicebuild.sh, default $PWD/build/
    TMPBUILD -- temporary output during rpm build, default $PWD/build/tmp

  [1]: https://github.com/m-lab/package/blob/master/templates/prepare.sh
  
Development
-----------

To iterate and test your slice on M-Lab, your workflow would look like:

  * Fork or clone your slice-support repository
  * Update init/* scripts or references to submodules
  * Build your package using `./package/slicebuild.sh`
  * Copy and install your package version to an M-Lab or PlanetLab node.
  * Install it and check for correct behavior.

If you are developing *INSIDE A SLICE*, then you need to make some special
accommodations:

  * First, choose two machines, one for development one for deployment testing.
  * On the first:
    - create a new user:
      * adduser <devfoo> 
    - checkout the appropriate support repo:
      * git clone --recursive https://github.com/m-lab/example-support
    - build it using your slicename:
      * ./package/slicebuild.sh <slicename>
    - copy the resulting package to the second machine.
  * On the second:
    - if this is an update, first run /usr/bin/slice-update. This will
      recreate your slice so your install is over a pristine filesystem. 
      (And, your ssh connection will be terminated because your slice and 
      all processes will be killed. Just log back in after a few minutes.)
    - install the rpm.
    - observe whether your slice operates correctly.
      * service slicectrl start
      * service slicectrl stop

Additional notes on the behavior of the slicebase system is [here][2].

  [2]: https://github.com/m-lab/package/tree/master/slicebase
