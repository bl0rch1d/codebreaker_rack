# frozen_string_literal: true

class BaseController
  PATHS = ['./app/views/', './app/views/partials/'].freeze
  DIFFICULTIES = CodebreakerDiz::DIFFICULTIES

  def self.find_views
    regex = Regexp.new('.+html.haml')

    views = { common: {}, partial: {} }

    PATHS.each_with_index do |path, index|
      Dir.entries(path).each do |file|
        views[views.keys[index]][file.split('.').first.intern] = file if file.match?(regex)
      end
    end

    views
  end

  VIEWS ||= find_views

  def initialize(request, session)
    @request  = request
    @session  = session

    @response = Rack::Response.new
  end

  private

  def show_page(name)
    @response.write(render(VIEWS[:common][name]))

    @response
  end

  def redirect_to(page)
    uri = page == :root ? '/' : "/#{page}"

    @response.redirect(uri)

    @response
  end

  def not_found
    @response.status = 404

    @response.write(render(VIEWS[:common][:'404']))

    @response
  end

  def render(template)
    view_path = template.match?(/^_/) ? 'partials/' + template : template

    path = File.expand_path("../../views/#{view_path}", __FILE__)

    Haml::Engine.new(File.read(path)).render(binding)
  end
end
