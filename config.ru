# frozen_string_literal: true

require_relative 'autoload'

use Rack::Reloader
use Rack::Session::Cookie, key: 'rack.session', path: '/', expire_after: 2_592_000, secret: 'unbreakable password'
use Middleware::AuthRedirectMiddleware
use Rack::Static, urls: ['/app/assets', '/node_modules'], root: './'

run CodebreakerRack
