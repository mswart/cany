require 'spec_helper'

describe Cany::Dpkg::Creator do

  context '#run' do
    let!(:dir) { Dir.mktmpdir }
    after { FileUtils.remove_entry dir}
    let(:spec) do
      s = Cany::Specification.new do
        name 'dpkg-creator-test'
        description 'Test Project'
        maintainer_name 'Hans Otto'
        maintainer_email 'hans.otto@example.org'
        website 'http://example.org'
        licence 'GPL-2+'
      end
      s.base_dir = dir
      s
    end
    let(:run) { Cany::Dpkg::Creator.new(spec).run }

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
        expect(subject).to have_the_content '8'
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
          'Standard-Version' => '3.9.2',
          'Build-Depends'    => 'debhelper (>= 7.0.50~), ruby',
          'Homepage'         => 'http://example.org'
        })

        expect(binary).to eq({
          'Package'     => 'dpkg-creator-test',
          'Architecture' => 'any',
          'Depends'     => '${shlibs:Depends}, ${misc:Depends}, ruby',
          'Description' => 'Test Project'
        })
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
  end
end