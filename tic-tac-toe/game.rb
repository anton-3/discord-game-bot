# frozen-string-literal: true

module TicTacToe
  # game logic
  class Game
    attr_reader :p1, :p2, :board

    SYMBOLS = { 1 => :x, 2 => :o }.freeze

    # randomize: whether or not to randomize who has the first move
    # which_ai: which users should be considered ai
    def initialize(user1, user2, randomize: false, which_ai: [false, false])
      @board = TicTacToe::Board.new(SYMBOLS[1], SYMBOLS[2])
      players = [user1, user2]
      create_players(players, which_ai, randomize)
    end

    def make_move(move, value)
      @board.move(move, value)
    end

    def to_s
      @board.to_s
    end

    def whose_turn
      # @p1 always goes first
      @board.turn_count.odd? ? @p1 : @p2
    end

    def win?
      @board.win?
    end

    def legal_move?(col)
      @board.legal_moves.include?(col)
    end

    def board_full?
      @board.full?
    end

    private

    def create_players(players, which_ai, randomize)
      order = [0, 1]
      order.shuffle! if randomize
      p_classes = []
      2.times { |num| p_classes.push(which_ai[num] ? TicTacToe::AIPlayer : TicTacToe::Player) }
      @p1 = p_classes[order[0]].new self, SYMBOLS[1], players[order[0]], 1
      @p2 = p_classes[order[1]].new self, SYMBOLS[2], players[order[1]], -1
    end
  end
end
