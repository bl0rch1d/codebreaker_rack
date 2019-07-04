# frozen_string_literal: true

module Middleware
  class AuthRedirectMiddleware
    AUTH_LOCATIONS = ['/game_results', '/hint', '/submit_answer'].freeze
    FREE_LOCATIONS = ['/', '/rules', '/statistics'].freeze

    private_constant :AUTH_LOCATIONS, :FREE_LOCATIONS

    attr_reader :status

    def initialize(app, status = 302)
      @app = app
      @status = status
    end

    def call(env)
      @request = Rack::Request.new(env)

      return [@status, { 'Location' => Router::URLS[:root] }, ['']] if !authenticated? && auth_location?

      return [@status, { 'Location' => Router::URLS[:game] }, ['']] if authenticated? && free_location?

      @app.call(env)
    end

    private

    def authenticated?
      @request.session.key?(:game) && @request.session.key?(:player)
    end

    def auth_location?
      AUTH_LOCATIONS.include?(@request.get_header('PATH_INFO'))
    end

    def free_location?
      FREE_LOCATIONS.include?(@request.get_header('PATH_INFO'))
    end
  end
end
