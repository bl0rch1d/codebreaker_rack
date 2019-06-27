# frozen_string_literal: true

class Router
  URLS = {
    root: '/',
    rules: '/rules',
    statistics: '/statistics',
    game: '/game',
    submit_answer: '/submit_answer',
    hint: '/hint',
    game_results: '/game_results'
  }.freeze

  def initialize(request, session)
    @request = request
    @controller = Controllers::AppController.new(request, session)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  def route!
    case @request.path
    when URLS[:root]          then @controller.index
    when URLS[:rules]         then @controller.rules
    when URLS[:statistics]    then @controller.statistics
    when URLS[:game]          then @controller.game
    when URLS[:submit_answer] then @controller.submit_answer
    when URLS[:hint]          then @controller.hint
    when URLS[:game_results]  then @controller.game_results
    else @controller.not_found
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
end
