# frozen_string_literal: true

class AppController < BaseController
  def initialize(request, session)
    super(request, session)

    @player, @game = session.load if session.present?
  end

  def index
    return redirect_to :game if @session.present?

    show_page :index
  end

  def rules
    return redirect_to :game if @session.present?

    show_page :rules
  end

  def statistics
    return redirect_to :game if @session.present?

    @data = Database.load

    show_page :statistics
  end

  def game
    return redirect_to :game if @session.present?

    return redirect_to :root unless @request[:player_name] && @request[:difficulty]

    return redirect_to :root unless validate_player

    initialize_player
    initialize_game

    @session.save(player: @player, game: @game)

    show_page :game
  end

  def hint
    return redirect_to :root unless @session.present?

    return redirect_to :game if @game.hints_count.zero?

    @hint = @game.generate_hint

    @session.save(player: @player, game: @game)

    show_page :game
  end

  def submit_answer
    return redirect_to :root unless @session.present?

    check_result = @game.check_guess(@request[:number])&.split('')

    @round_result = check_result + Array.new(CodebreakerDiz::CODE_LENGTH - check_result.size)

    @session.save(player: @player, game: @game)

    return show_results if game_finished?

    show_page :game
  end

  def show_results
    @status = @game.lose? ? :lose : :win

    save_results if @status == :win

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
end
