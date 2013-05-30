M-Lab Slicebase
===============

The slicebase is a set of conventions and standard services for M-lab slices
that are automatically bundled with slices packaged using the
m-lab-tools/package module.

The following outline the utility of each part.

Support Scripts
===============

 * `slicebase/init/post-init

    Once the slice package is installed, this script performs post installation
    initialization.  In particular, it will:

     * enable the `rsyslog` service using chkconfig.
     * enable the `crond` service using chkconfig.
     * enable the `rsyncd` service using chkconfig.
     * configure `/etc/rsyncd.conf`
     * enable the `slicectrl` service using chkconfig.

 * `slicebase/mlab/slicectrl-functions`

    `slicectrl-functions` provides all the support logic for `slicectrl`.

User Scripts and Commands
=========================

The following commands are available to users.

 * `slicebase/bin/slice-restart`

    This command simulates a restart, except it applies only to the calling
    slice. All slice processes are killed (including active SSH connections) and
    the slice is started again. System services are restarted via initscripts.

 * `slicebase/bin/slice-update`

    This command performs reinstallation.  Like restart, all processes are
    killed. Next, for M-Lab managed slices, this means that the slice data
    directory `$SLICERSYNCDIR` is preserved, then the filesystem deleted, a new
    filesystem is created, the data directory restored, and the slice package
    installed.  All updates are performed using `slice-update`.
    
 * `slicebase/etc/init.d/rsyncd`
    
    This initscript controls the rsync daemon.  The rsync daemon provides
    read-only access to the experiment logs stored in `$SLICERSYNCDIR`.  This is
    how M-Lab collects data from experiments before publishing it in cloud
    storage and importing it into BigQuery for analysis.

 * `slicebase/etc/init.d/slicectrl`
    
    This initscript is a wrapper for the slice itself.  When calling `start`,
    `stop`, or `initialize`, the initscript looks for slice-provided scripts in
    `$SLICEHOME/init/` and executes the appropriate one.

    More information on these scripts can be found here: add-link.

 * `slicebase/mlab/slice-functions`

    This file is available for slice-provided scripts.  In particular it defines
    several useful values and functions for configuration and operation.

    More information on this can be found here: add-link.
