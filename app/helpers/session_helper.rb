# frozen_string_literal: true

class SessionHelper
  def initialize(request)
    @request = request
  end

  def save(data)
    @request.session[:player] = data[:player]
    @request.session[:game]   = data[:game]
  end

  def load
    player = @request.session[:player]
    game   = @request.session[:game]

    [player, game]
  end

  def destroy
    @request.session.clear
  end

  def present?
    @request.session.key?(:game) && @request.session.key?(:player)
  end
end
