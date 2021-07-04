# frozen-string-literal: true

module Connect4
  # logic for all connect 4 players
  class Player
    attr_reader :game, :color, :user, :name, :value

    def initialize(game, color, user, value)
      @game = game
      @color = color
      @user = user
      @value = value
      @name = user.display_name
    end

    def make_move(move)
      @game.make_move(move, @value)
    end
  end
end
