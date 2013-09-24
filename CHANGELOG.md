0.1.2 / 2013-09-24
==================

Buf Fixes:
  
  * dpkg: fix build error with --no-arch-all
  * recipe: fix web server pre start scripts


0.1.1 / 2013-09-24
==================

Bug Fixes:

  * DPKG: create compat 8 level files - no multiarch problems


0.1.0 / 2013-09-24
==================

Features:

  + Support recipe hooks
  + Support recipe (configuration) option
  + Rewritten and extended dependency management
  + Support (source) package generation adjustments by recipes
  + canspec: new require_cany directive
  + Support per rails configuration
  + Refactored init script management (supports multiple services per package)
  + sidekiq recipe
  + unicorn recipe

Bug fixes:

  * rails: export RAILS_ENV in wrapper script
  * bundler: add some more gem dependencies
  * recipe: exit on failed command (like bundle install)
  * dpkg: create compat 9 packages


0.0.2 / 2013-09-13
==================

Bug fixes:

  * rails: run asset compilation inside assets environment
  * dpkg: replace hard coded package name
  * rails: run rake inside bundle
  * recipe: use same ruby intepreter as for cany


0.0.1 / 2013-09-12
==================

  * Basic support to pack a rails application
