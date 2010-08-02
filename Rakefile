require 'rubygems'
require "bundler"
Bundler.setup


require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--color", "--backtrace"]
  t.ruby_opts = ['-rubygems']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "megaleech"
    gemspec.summary = "Megaleech uses your Google Reader account to automatically add starred torrents to Rtorrent"
    gemspec.description = "Megaleech uses your Google Reader account to automatically add starred torrents to Rtorrent"
    gemspec.files = FileList["lib/**/*.rb", "lib/megaleech/config/.megaleech.rc", "bin/*"]
    gemspec.homepage = "http://github.com/ragaskar/megaleech"
    gemspec.author = "Rajan Agaskar"
    gemspec.email = "ragaskar@gmail.com"
    gemspec.add_dependency("xmlrpcs", "0.1.3")
    gemspec.add_dependency("scgi", "0.9.1")
    gemspec.add_dependency("mechanize", "1.0.0")
    gemspec.add_dependency("nokogiri", "1.4.3.1")
    gemspec.add_dependency("bencode", "0.6.0")
    gemspec.add_dependency("sequel", "3.13.0")
    gemspec.add_dependency("sqlite3-ruby", "1.3.1")
    gemspec.add_dependency("daemons", "1.1.0")
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
