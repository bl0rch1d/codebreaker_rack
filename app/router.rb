# frozen_string_literal: true

class Router
  URLS = {
    index: '/',
    rules: '/rules',
    statistics: '/statistics',
    game: '/game',
    submit_answer: '/submit_answer',
    hint: '/hint'
  }.freeze

  def initialize(request, session)
    @request = request
    @controller = AppController.new(request, session)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  def route!
    case @request.path
    when URLS[:index]         then @controller.index
    when URLS[:rules]         then @controller.rules
    when URLS[:statistics]    then @controller.statistics
    when URLS[:game]          then @controller.game
    when URLS[:submit_answer] then @controller.submit_answer
    when URLS[:hint]          then @controller.hint
    else @controller.not_found
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
end
