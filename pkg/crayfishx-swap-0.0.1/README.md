puppet-swap
===========

Puppet resource type and provider for managing swap paging space

Usage
=====

swap { 'hd6':
  size => '1024M',
}

Caveats
=======

Currently only supports AIX provider
