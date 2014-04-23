#!/usr/bin/env rake
require 'rspec/core/rake_task'
require 'fileutils'
require './lib/fruit_to_lime/templating.rb'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec

require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks({:dir=>File.dirname(__FILE__),:name=>'fruit_to_lime'})


task :install_fruit_to_lime do
    sh "bundle install"
end

require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'

task :uninstall_fruit_to_lime do
    ['fruit_to_lime','fruit-to-lime'].each do |tool|
        begin
            Gem::GemRunner.new.run ['uninstall', tool, '-a', '-x']
        rescue Gem::SystemExitException => e
            puts e
        end
    end
end

desc "test fruit to lime gem"
task :test_fruit_to_lime => [:uninstall_fruit_to_lime, :install_fruit_to_lime, :spec] 

desc "cleans temporary templates folder"
task :clean_temporary_templates_folder do
	unpack_path = File.expand_path("unpacked", Dir.tmpdir)
	FileUtils.remove_dir(unpack_path, true)
	FileUtils.mkdir(unpack_path)
end

def execute_command_with_success_for_template(cmd, template)
	system(cmd)
	if ! $?.success?
		puts "Failed with #{$?}"
		raise "failed! #{cmd} for template #{template}"
	end
end

def unpack_template_and_run_specs(template)
	unpack_path = File.expand_path("unpacked", Dir.tmpdir)
	templating = FruitToLime::Templating.new('templates')
	templating.unpack template, unpack_path
	Dir.chdir(File.expand_path(template, unpack_path)) do
		execute_command_with_success_for_template('rake spec', template)
	end
end


desc "csv template spec"
task :csv_template_spec => [:clean_temporary_templates_folder] do
	unpack_template_and_run_specs 'csv'
end