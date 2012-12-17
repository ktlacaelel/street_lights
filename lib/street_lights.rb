require 'fileutils'
require 'isna'

class StreetLights

  def initialize(app)
    @app = app
    @street_lights_dir = 'street_lights/'
    unless File.exists?(@street_lights_dir)
      FileUtils.mkdir_p(@street_lights_dir)
    end
    at_exit { File.rm "#{@street_lights_dir}/#{Process.pid}" }
  end

  def call(env)
    File.open("#{@street_lights_dir}/#{Process.pid}", 'w+') do |file|
      file.puts "#{Process.pid.to_s.to_ansi.red.to_s} #{env['HTTP_HOST']} #{env['REQUEST_PATH']}"
    end
    status, headers, response = @app.call(env)
    File.open("#{@street_lights_dir}/#{Process.pid}", 'w+') do |file|
      file.puts "#{Process.pid.to_s.to_ansi.green.to_s}"
    end
    [status, headers, response]
  end

end

