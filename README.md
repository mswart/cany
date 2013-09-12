# Cany

Cany is a toolkit to create easily distribution packages from your (ruby) application. The goal is to reduce the packaging work to managing the application meta data (specification).

The goal is to support all (common) package manager - all from the some specification, although at the moment is only dpkg implemented.


## Installation

Cany is a rubygem, it needs **ruby >=1.9.3** to work. But it is design to be lightweight. Therefore a:

    $ gem install cany

is enough to install it. But you can add is also to your application's Gemfile:

```ruby
gem 'cany'
```

And then execute:

    $ bundle

To let bundle install it for you.


## Write a Specification for your Application

Create a file ``<your application name>.canspec`` inside your application folder:

```ruby
Cany::Specification.new do
  name 'example-application' # This is used as package name - please you only ASCII letters, - and literals.
  version '0.1' # Your application's version
  description 'This example application is used to have a application for that this README can describe how it is packaged with cany' # A short description for you application. Should not longer than a few paragraphs
  maintainer_name 'Hans Otto' # The person/organisation maintaining the package
  maintainer_email 'hans.otto@example.org' # A eMail address to contact the maintainer
  website 'http://example.org/cany' # A website to get more information about the application
  licence 'MIT' # Your Licence

  # Use common build tasks to build your application - describe how your application needs to be build
  use :bundler
  use :rails
end
```

### Recipes

See the next section for documentation about the known recipes. Please be aware that the ordering of use commands is important.

### Own Adjustments

There are applications were the known recipes are not sufficient to build it. You can define blocks inside the canspec that are runs like normal recipes and allow you to do specific tasks.

The following example installs an additional folder (of an Ruby on Rails applications):

```ruby
Cany::Sepcification.new do
  # meta data and recipe loading
  binary do
    install 'additional_subdir', "/usr/share/#{spec.name}"
  end
end
```


## Recipes

Cany uses different recipes to share different packaging tasks above multiple applications.

### Bundler

All common applications need a bunch of gems. Bundle is the common tool to manage these gems. Because for most of the gems there exists no packages, we decide that the best approach is to ship the installed gems with the application.

This recipe is designed to use as first one. The installs bundler and uses the ``Gemfile.lock`` to install the referenced gems to ``vendor/bundle``.

### Rails

This recipe is used to install a ruby on rails application. The recipes installs the different files/directories.

### Thin

This recipe configures thin and install an init script to launch the application. It assumes that thin is listed in your Gemfile.



## Use Your Specification to Create Packages

To create dpkg packages (used by debian and its derivatives) run from your application directory with your canspec:

    $ cany dpkg-create

It creates a debian subdirectory containing all needed files/information to build a dpkg package in the debian way. To create the package itself cany relies on the debian packaging tools. The build your package without signing the created files with GPG run

    $ dpkg-buildpackage -us -uc

Afterwards you should have ``*.deb`` package in the directory containing your application directory.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
