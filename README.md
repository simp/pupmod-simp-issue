[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/issue.svg)](https://forge.puppetlabs.com/simp/issue)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/issue.svg)](https://forge.puppetlabs.com/simp/issue)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-issue.svg)](https://travis-ci.org/simp/pupmod-simp-issue)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with issue](#setup)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Description

This module manages `/etc/issue` and `/ets/issue.net`, and has several available
file examples.

### This is a SIMP module

This module is a component of the [System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, they may be submitted to our [bug tracker](https://simp-project.atlassian.net/).

This module is optimally designed for use within a larger SIMP ecosystem, but it can be used independently:

 * When included within the SIMP ecosystem, security compliance settings will be managed from the Puppet server.
 * If used independently, all SIMP-managed security subsystems are disabled by default and must be explicitly opted into by administrators.  Please review the parameters in [`simp/simp_options`](https://github.com/simp/pupmod-simp-simp_options) for details.


## Setup


Include the class to use it:

``` ruby
class { 'issue':
  profile => 'us_doc'
}
```

## Reference

Available issue files are:
  * default
  * lite
  * us_doc
  * us_doc_lite
  * us_dod
  * us_noaa

They can be read in entirety in the `files/issue` directory.

Please refer to the inline documentation within each source file, or to the module's generated YARD documentation for reference material.


## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise Linux and compatible distributions, such as CentOS. Please see the [`metadata.json` file](./metadata.json) for the most up-to-date list of supported operating systems, Puppet versions, and module dependencies.


## Development

Please read our [Contribution Guide] (http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html).
