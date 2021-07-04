# frozen-string-literal: true

module TicTacToe
  # logic for all tic tac toe players
  class Player
    attr_reader :game, :symbol, :user, :name, :value

    def initialize(game, symbol, user, value)
      @game = game
      @symbol = symbol
      @user = user
      @value = value
      @name = user.display_name
    end

    def make_move(move)
      @game.make_move(move, @value)
    end
  end
end
