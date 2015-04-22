require 'rubygems'
require 'rubygems/package_task'
gem 'rdoc'
require 'rake/testtask'
require 'rdoc/rdoc'
require 'rdoc/task'

PKG_NAME    = 'thread_executor'
PKG_VERSION = '1.0.0'

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = 'Thread executor library.'
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.requirements = []
  s.files = FileList[ 'README.md', 'lib/**/*rb', 'bin/*' ]
  s.executables = []
  s.require_path = 'lib'
  s.required_ruby_version = '>= 2.0.0'

  s.extra_rdoc_files = [ 'README.md', 'Changelog' ]
  s.author = 'Sam Baskinger'
  s.email = 'basking2@yahoo.com'
  s.homepage = 'http://sam.baskinger.tiddlyspot.com'
  s.license = 'BSD'
  s.description = <<EOF
  Thread executor library.
EOF
end

Gem::PackageTask.new( spec ) do |pkg|
  pkg.need_tar_bz2 = true
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_*.rb']
  # t.verbose = true
end

RDoc::Task.new do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include( "README.md", "lib/**/*.rb" )
  rd.options << "--all"
end

task :all => [ :test, :rdoc, :package ]
task :default => [ :test, :rdoc, :package ]

