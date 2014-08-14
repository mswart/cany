0.5.3 / 2014-08-14
==================

Bug Fixes:

  * Use bundler 1.6.x for now - as 1.7 has difficulties with basic auth protected sources (II)


0.5.2 / 2014-08-14
==================

Bug Fixes:

  * Use bundler 1.6.x for now - as 1.7 has difficulties with basic auth protected sources


0.5.1 / 2014-01-09
==================

Bug Fixes:

  * Specify native dependencies for rmagick


0.5.0 / 2013-10-25
==================

Feature:

  * Support custom prepare and clean actions in specification


0.4.0 / 2013-10-24
==================

Feature:

  * bundler: Option to ignore additional Gemfile groups

Bug Fixes:

  * bundler: Fix gem install bundler with ruby 2.0 (work around)


0.3.0 / 2013-10-23
==================

Feature:

  * rails: Option to specify rails env for assets precompiling


0.2.1 / 2013-10-23
==================

Bug Fixes:

  * Fix dependency for ethon


0.2.0 / 2013-09-25
==================

Feature:

  * sidekiq: option to specify as which user and group sidekiq should run
  * web server: option to specify as which user and group the web server should run (thin, unicorn)


0.1.3 / 2013-09-25
==================

Bug Fixes:

  * unicorn: fix launch command


0.1.2 / 2013-09-24
==================

Bug Fixes:

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
