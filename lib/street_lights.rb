require 'fileutils'
require 'isna'

class StreetLights

  def initialize(app)
    @app = app
    @street_lights_dir = 'street_lights/'
    unless File.exists?(@street_lights_dir)
      FileUtils.mkdir_p(@street_lights_dir)
    end
    shutdown_behaviour = proc do
      FileUtils.rm(street_light) if File.exists?(street_light)
    end
    trap('QUIT', &shutdown_behaviour)
    trap('TERM', &shutdown_behaviour)
    trap('EXIT', &shutdown_behaviour)
    trap('KILL', &shutdown_behaviour)
  end

  def street_light
    @street_light ||= "#{@street_lights_dir}/#{Process.pid}"
  end

  def call(env)
    File.open(street_light, 'w+') do |file|
      file.puts "#{Process.pid.to_s.to_ansi.red.to_s} #{env['HTTP_HOST']} #{env['REQUEST_PATH']}"
    end
    status, headers, response = @app.call(env)
    File.open(street_light, 'w+') do |file|
      file.puts "#{Process.pid.to_s.to_ansi.green.to_s}"
    end
    [status, headers, response]
  end

end

