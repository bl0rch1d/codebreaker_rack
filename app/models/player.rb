# frozen_string_literal: true

class Player
  attr_reader :name, :difficulty

  def initialize(name, difficulty)
    @name = name
    @difficulty = difficulty
  end

  class << self
    def name_valid?(input)
      input.instance_of?(String) && input.length.between?(3, 20)
    end

    def difficulty_valid?(input)
      CodebreakerDiz::DIFFICULTIES.key?(input.to_sym.downcase)
    end
  end
end
