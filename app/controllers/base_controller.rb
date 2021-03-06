# frozen_string_literal: true

module Controllers
  class BaseController
    DIFFICULTIES = CodebreakerDiz::DIFFICULTIES
    PATHS = ['./app/views/', './app/views/partials/'].freeze

    private_constant :PATHS

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

    def self.views
      @views ||= find_views
    end

    def initialize(request, session)
      @request  = request
      @session  = session

      @response = Rack::Response.new
    end

    private

    def show_page(name)
      @response.write(render(self.class.views[:common][name]))

      @response
    end

    def redirect_to(page)
      uri = page == :root ? '/' : "/#{page}"

      @response.redirect(uri)

      @response
    end

    def not_found
      @response.status = 404

      @response.write(render(self.class.views[:common][:'404']))

      @response
    end

    def render(template)
      view_path = template.match?(/^_/) ? 'partials/' + template : template

      path = File.expand_path("../../views/#{view_path}", __FILE__)

      Haml::Engine.new(File.read(path)).render(binding)
    end
  end
end
