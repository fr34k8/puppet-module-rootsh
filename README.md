# RootSH
===

[![Build Status](https://travis-ci.org/juliengk/puppet-module-rootsh.png?branch=master)](https://travis-ci.org/juliengk/puppet-module-rootsh)

This is a Puppet module for managing RootSH program. It is capable of ensuring
rootsh is installed either from package or compile from source, and make sure log directory is created.

===

# Parameters
------------

## Resource parameters
---

ensure
------

- *Default*: 'present'

package_name
------------

- *Default*: 'rootsh'

package_provider
----------------

- *Default*: undef

from_source
-----------

- *Default*: false

source_file
-----------
Source file can be found at the following url: http://sourceforge.net/projects/rootsh/

- *Default*: 'UNSET'

log_path
--------

- *Default*: 'USE_DEFAULTS'

log_owner
---------

- *Default*: 'root'

log_group
---------

- *Default*: 'root'

log_mode
--------

- *Default*: '0755'

rsyslog_conf_content
--------------------

- *Default*: 'MANDATORY'
