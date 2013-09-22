0.1.0 / 2013-09-23
==================

Features:

  + Support recipe hooks
  + Support recipe (configuration) option
  + Rewritten and extended dependency management
  + Support (source) package generation adjustments by recipes
  + canspec: new require_cany directive
  + Support per rails configuration

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
