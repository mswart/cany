#
# Guardfile -- for RSpec
#

guard 'rspec', all_after_pass: true, all_on_start: true do
  watch(%r{^spec/(.+)_spec\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('spec/spec_helper.rb')                        { "spec" }
end

# load Guardfile.local
local_guardfile = File.dirname(__FILE__) + "/Guardfile.local"
if File.file?(local_guardfile)
  self.instance_eval(Bundler.read_file(local_guardfile))
end
