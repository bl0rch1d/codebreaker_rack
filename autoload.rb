# frozen_string_literal: true

require 'yaml'
require 'haml'
require 'i18n'
# require 'pry'

require 'codebreaker_diz'

require_relative './config/initializers/i18n'

require_relative './app/models/player'
require_relative './app/database'
require_relative './app/helpers/session_helper'
require_relative './app/controllers/base_controller'
require_relative './app/controllers/app_controller'
require_relative './app/router'
require_relative './app/codebreaker_rack'

I18n.config.load_path << Dir[File.expand_path('config/locales') + '/*.yml']
