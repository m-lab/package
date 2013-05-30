M-Lab Slicebase
===============

The slicebase is a set of standard services and conventions for M-lab slices.
The files here are automatically bundled with slices packaged using the
m-lab-tools/package module.

The following outline the utility of each part.  More details should be
available in the comments of each file.

Support Scripts
---------------

* `slicebase/init/post-init`

   Once the slice package is installed, `post-init` performs post installation
   setup.  In particular, it will:

   * enable the `rsyslog` service using chkconfig.
   * enable the `crond` service using chkconfig.
   * configure `/etc/rsyncd.conf`
   * enable the `rsyncd` service using chkconfig.
   * enable the `slicectrl` service using chkconfig.

* `slicebase/mlab/slicectrl-functions`

   The `slicectrl` initscript uses `slicectrl-functions` for all support logic.

User Scripts and Commands
-------------------------

The following commands are available to users.

* `slicebase/bin/slice-restart`

   Simulates a restart. Except slice-restart applies only to the calling slice.
   All slice processes are killed (including active SSH connections) and the
   slice is started again. System services are restarted via initscripts.

* `slicebase/bin/slice-update`

   Performs reinstallation.  Like restart, all processes are killed. Next, for
   M-Lab managed slices, this means that the slice data directory
   `$SLICERSYNCDIR` is preserved, then the filesystem deleted, a new filesystem
   is created, the data directory restored, and the slice package installed.
   All updates are performed using `slice-update`.
    
* `slicebase/etc/init.d/rsyncd`
    
   An initscript to control the rsync daemon.  The rsync daemon provides
   read-only access to the experiment logs stored in `$SLICERSYNCDIR`.  This is
   how M-Lab collects data from experiments before publishing it in cloud
   storage and importing it into BigQuery for analysis.

* `slicebase/etc/init.d/slicectrl`
    
   An initscript to wrap operation of the slice itself.  When calling `start`,
   `stop`, or `initialize`, the initscript looks for slice-provided scripts in
   `$SLICEHOME/init/` and executes the appropriate one.

   More information on these scripts can be found here: add-link.

* `slicebase/mlab/slice-functions`

   This file is available for slice-provided scripts.  In particular it defines
   several useful values and functions for configuration and operation.

   More information on this can be found here: add-link.
