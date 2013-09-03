RSpec::Matchers.define :be_a_directory do
  match do |actual|
    File.directory? actual.to_s
  end
end

RSpec::Matchers.define :be_a_file do
  match do |actual|
    File.file? actual.to_s
  end
end

RSpec::Matchers.define :have_the_content do |expected|
  match do |actual|
    File.read(actual.to_s) == expected
  end
end

RSpec::Matchers.define :be_executable do
  match do |actual|
    File.executable? actual.to_s
  end
end
