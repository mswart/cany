require 'spec_helper'

describe Cany::Dpkg::Creator do

  context '#run' do
    let!(:dir) { Dir.mktmpdir }
    after { FileUtils.remove_entry dir}
    let(:spec) do
      s = Cany::Specification.new do
        name 'dpkg-creator-test'
        version '0.1'
        description 'Test Project'
        maintainer_name 'Hans Otto'
        maintainer_email 'hans.otto@example.org'
        website 'http://example.org'
        licence 'GPL-2+'
      end
      s.base_dir = dir
      s
    end
    let(:run) { Cany::Dpkg::Creator.new(spec).run *(@run_args || []) }

    context 'debian directory' do
      subject { File.join dir, 'debian' }

      it do
        run
        expect(subject).to be_a_directory
      end
    end

    context 'source format file' do
      subject { File.join dir, 'debian', 'source', 'format' }

      it do
        run
        expect(subject).to be_a_file
        expect(subject).to have_the_content '3.0 (native)'
      end
    end

    context 'compat file' do
      subject { File.join dir, 'debian', 'compat' }

      it do
        run
        expect(subject).to be_a_file
        expect(subject).to have_the_content '9'
      end
    end

    context 'control file' do
      let(:filename) { File.join dir, 'debian', 'control' }
      subject { DebControl::ControlFileBase.read filename }

      it do
        run
        expect(subject.paragraphs.size).to eq 2
        source = subject.paragraphs.first
        binary = subject.paragraphs[1]

        expect(source).to eq({
          'Source'           => 'dpkg-creator-test',
          'Section'          => 'ruby',
          'Priority'         => 'optional',
          'Maintainer'       => 'Hans Otto <hans.otto@example.org>',
          'Standards-Version' => '3.9.2',
          'Build-Depends'    => 'debhelper (>= 7.0.50~), ruby, ruby-dev',
          'Homepage'         => 'http://example.org'
        })

        expect(binary).to eq({
          'Package'     => 'dpkg-creator-test',
          'Architecture' => 'any',
          'Depends'     => '${shlibs:Depends}, ${misc:Depends}, ruby',
          'Description' => 'Test Project'
        })
      end

      it 'use the specified ruby packages' do
        @run_args = %w(--ruby-deb ruby2.0)
        run
        expect(subject.paragraphs.size).to eq 2
        source = subject.paragraphs.first
        binary = subject.paragraphs[1]

        expect(source).to eq({
                                 'Source'           => 'dpkg-creator-test',
                                 'Section'          => 'ruby',
                                 'Priority'         => 'optional',
                                 'Maintainer'       => 'Hans Otto <hans.otto@example.org>',
                                 'Standards-Version' => '3.9.2',
                                 'Build-Depends'    => 'debhelper (>= 7.0.50~), ruby2.0, ruby2.0-dev',
                                 'Homepage'         => 'http://example.org'
                             })

        expect(binary).to eq({
                                 'Package'     => 'dpkg-creator-test',
                                 'Architecture' => 'any',
                                 'Depends'     => '${shlibs:Depends}, ${misc:Depends}, ruby2.0',
                                 'Description' => 'Test Project'
                             })
      end

      it 'use the specified ruby' do
        @run_args = %w(--ruby ruby2.0)
        run
        expect(subject.paragraphs.size).to eq 2
        source = subject.paragraphs.first
        binary = subject.paragraphs[1]

        expect(source).to eq({
                                 'Source'           => 'dpkg-creator-test',
                                 'Section'          => 'ruby',
                                 'Priority'         => 'optional',
                                 'Maintainer'       => 'Hans Otto <hans.otto@example.org>',
                                 'Standards-Version' => '3.9.2',
                                 'Build-Depends'    => 'debhelper (>= 7.0.50~), ruby2.0, ruby2.0-dev',
                                 'Homepage'         => 'http://example.org'
                             })

        expect(binary).to eq({
                                 'Package'     => 'dpkg-creator-test',
                                 'Architecture' => 'any',
                                 'Depends'     => '${shlibs:Depends}, ${misc:Depends}, ruby2.0',
                                 'Description' => 'Test Project'
                             })
      end

      it 'should add extra deps in specific gems are used' do
        FileUtils.copy File.expand_path('../../fixtures/testgem.lock', __FILE__), File.join(dir, 'Gemfile.lock')
        run
        expect(subject.paragraphs.size).to eq 2
        source =
        binary = subject.paragraphs[1]
        src_deps = subject.paragraphs.first['Build-Depends'].gsub(', ', ',').split(',')
        bin_deps = subject.paragraphs[1]['Depends'].gsub(', ', ',').split(',')

        expect(src_deps).to include('libpq-dev')
        expect(bin_deps).to include('libpq5')
      end
    end

    context 'copyright file' do
      let(:filename) { File.join dir, 'debian', 'copyright' }
      subject { DebControl::ControlFileBase.read filename }

      it do
        run
        expect(subject.paragraphs.size).to eq 2

        expect(subject.paragraphs.first).to eq({
          'Format' => 'http://dep.debian.net/deps/dep5',
          'Upstream-Name' => 'dpkg-creator-test',
        })

        expect(subject.paragraphs[1]).to eq({
          'Files' => '*',
          'Copyright' => "#{Time.now.year} Hans Otto",
          'Licence' => "GPL-2+\n[LICENCE TEXT]"
        })
      end
    end

    context 'rules file' do
      let(:filename) { File.join dir, 'debian', 'rules' }
      subject { File.read filename }

      it do
        run

        expect(filename).to be_executable

        expect(subject).to start_with '#!/usr/bin/make -f'
        expect(subject).to include "export PATH := debian/bin:${PATH}\n"
        expect(subject).to include "export GEM_PATH := debian/gems:${GEM_PATH}\n"
        expect(subject).to include "\truby -S cany dpkg-builder $@"
        expect(subject).to include "\truby -cS cany >/dev/null || ruby -S gem install --no-ri --no-rdoc --install-dir debian/gems --bindir debian/bin $${CANY_GEM:-cany}"
        expect(subject).to include "override_dh_prep:"
      end

      it 'should use the selected interpreter' do
        @run_args = '--ruby-exe', 'ruby1.9.1'
        run

        expect(filename).to be_executable

        expect(subject).to start_with '#!/usr/bin/make -f'
        expect(subject).to include "\truby1.9.1 -S cany dpkg-builder $@"
        expect(subject).to include "\truby1.9.1 -cS cany >/dev/null || ruby1.9.1 -S gem install --no-ri --no-rdoc --install-dir debian/gems --bindir debian/bin $${CANY_GEM:-cany}"
      end

      it 'should use the current ruby' do
        @run_args = '--ruby', 'ruby1.9.1'
        run

        expect(filename).to be_executable

        expect(subject).to start_with '#!/usr/bin/make -f'
        expect(subject).to include "\truby1.9.1 -S cany dpkg-builder $@"
        expect(subject).to include "\truby1.9.1 -cS cany >/dev/null || ruby1.9.1 -S gem install --no-ri --no-rdoc --install-dir debian/gems --bindir debian/bin $${CANY_GEM:-cany}"
      end
    end

    context 'changelog file' do
      let(:filename) { File.join dir, 'debian', 'changelog' }
      subject { File.read filename }

      it do
        Timecop.freeze(Time.new(2013, 8, 14, 1, 18, 51, 2)) do
          run
        end
        expect(subject).to eq 'dpkg-creator-test (0.1-1) unstable; urgency=low

  * Build with cany

 -- Hans Otto <hans.otto@example.org>  Wed, 14 Aug 2013 01:18:51 +0000'
      end
    end
  end
end
