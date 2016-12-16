require 'spec_helper'

describe Cany::Dpkg::DebHelperRecipe do
  let!(:dir) { Dir.mktmpdir }
  before do
    Dir.mkdir File.join(dir, 'debian')
    @old_path = Dir.pwd
    Dir.chdir(dir)
  end
  after do
    Dir.chdir @old_path
    FileUtils.remove_entry dir
  end
  let(:spec) do
    s = Cany::Specification.new do
      name 'test'
      description 'Your RSpec Upstart-Scripts'
    end
    s.base_dir = dir
    s
  end
  let(:recipe) { described_class.new spec }
  subject { recipe }

  describe '#binary' do
    it 'should install services' do
      should receive(:install_services)
      subject.binary
    end
    it 'should install base service' do
      should receive(:install_base_service)
      subject.binary
    end
  end

  describe '#install_services' do
    before do
      recipe.install_service :service, %w(hans args1), user: 'www-data', group: 'www-data'
      recipe.install_services
    end
    subject { File.read File.join(dir, 'debian', 'test.test-service.upstart') }

    it 'should create files' do
      should eq <<EOF
description "Your RSpec Upstart-Scripts - service"

start on started test
stop on stopping test

respawn
respawn limit 10 5
umask 022

chdir /usr/share/test

setuid www-data
setgid www-data

exec hans args1
EOF
      expect(@executed_programs).to match_array [['dh_installinit', '--name', 'test-service']]
    end
  end

  describe '#install_base_services' do
    before do
      recipe.configure :service_pre_scripts, mkdir_run: "mkdir /var/run/#{spec.name}", chown_run: "chown www-data /var/run/#{spec.name}"
      Dir.chdir(dir) { recipe.install_base_service }
    end
    subject { File.read File.join(dir, 'debian', 'test.upstart') }
    it 'should create files' do
      should eq <<EOF
description "Your RSpec Upstart-Scripts"

start on filesystem or runlevel [2345]
stop on runlevel [!2345]

respawn
respawn limit 10 5
umask 022

pre-start script
  mkdir /var/run/test
  chown www-data /var/run/test
end script

exec sleep 365d
EOF
    end
  end
end
