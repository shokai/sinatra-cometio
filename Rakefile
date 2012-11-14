require 'rubygems'
gem 'hoe', '>= 3.1.0'
require 'hoe'
require 'fileutils'
require './lib/sinatra-cometio'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'sinatra-cometio' do
  self.developer 'Sho Hashimoto', 'hashimoto@shokai.org'
  self.rubyforge_name       = self.name # TODO this is default value
  self.extra_deps         = [['sinatra','>= 1.3.3'],
                             ['eventmachine', '>= 1.0.0'],
                             ['json'],
                             ['sinatra-contrib', '>= 1.3.2'],
                             ['event_emitter', '>= 0.1.0']]

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
