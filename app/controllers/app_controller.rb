# frozen_string_literal: true

module Controllers
  class AppController < BaseController
    def initialize(request, session)
      super(request, session)

      @player, @game = session.load if session.present?

      @response_data = {}
    end

    def index
      show_page :index
    end

    def rules
      show_page :rules
    end

    def statistics
      @response_data[:statistics] = Database.load

      show_page :statistics
    end

    def game
      return show_page :game if @session.present?

      return redirect_to :root unless params? && validate_player

      initialize_player
      initialize_game

      @session.save(player: @player, game: @game)

      show_page :game
    end

    def submit_answer
      obtain_guess_result

      return redirect_to :game if @game.errors.include?(CodebreakerDiz::GuessFormatError)

      @session.save(player: @player, game: @game)

      return redirect_to :game_results if game_finished?

      show_page :game
    end

    def hint
      return redirect_to :game if @game.hints_count.zero?

      obtain_hint

      @session.save(player: @player, game: @game)

      show_page :game
    end

    def game_results
      return redirect_to :game if @session.present? && !game_finished?

      @response_data[:status] = @game.lose? ? :lose : :win

      save_results if @response_data[:status] == :win

      @session.destroy

      show_page :game_results
    end

    def not_found
      super
    end

    private

    def save_results
      data = @game.data
      data[:player_name] = @player.name
      data[:datetime] = Time.now.strftime('%d %b %Y - %H:%M:%S')

      Database.save(data)
    end

    def obtain_guess_result
      @game.errors.clear
      @game.check_guess(@request[:number])&.split('')
    end

    def obtain_hint
      @game.generate_hint
    end

    def validate_player
      Player.name_valid?(@request[:player_name]) && Player.difficulty_valid?(@request[:difficulty])
    end

    def initialize_player
      @player = Player.new(@request[:player_name], @request[:difficulty])
    end

    def initialize_game
      @game = CodebreakerDiz::Game.new(difficulty: @request[:difficulty].intern)
    end

    def game_finished?
      @game.win? || @game.lose?
    end

    def params?
      @request[:player_name] && @request[:difficulty]
    end
  end
end
