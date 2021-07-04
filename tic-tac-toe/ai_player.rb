# frozen-string-literal: true

module TicTacToe
  # logic for an ai player that always finds the best move
  class AIPlayer < TicTacToe::Player
    LOG_MOVES = false

    def initialize(*)
      super
      @board = @game.board
      @cutoff_depth = 1000
    end

    def find_random_move
      @board.legal_moves.sample
    end

    def find_best_move
      return 4 if @board.turn_count == 1

      moves = {}

      @board.legal_moves.each do |move|
        copy = Marshal.load(Marshal.dump(@board))
        copy.move(move, @value)
        score = -minimax(copy, -@value)
        moves[move] = score
      end

      best_moves = moves.select { |_move, score| score == moves.values.max }.keys
      move = best_moves.sample # if there are multiple best moves with the same value, choose a random one
      log(moves, move) if LOG_MOVES
      move
    end

    private

    # calculates every possible outcome from a given board position and scores it for a given player
    # board: the board scored by the minimax function
    # p_value: the value of the player that's being scored for, either 1 or -1
    # depth: the recursive depth of the function
    # alpha and beta: alpha beta pruning https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning
    def minimax(board, p_value, depth = 0, alpha = -10000, beta = 10000)
      return 0 if board.full?
      return -1000 + depth if board.win?

      board.legal_moves.each do |move|
        copy = Marshal.load(Marshal.dump(board))
        copy.move(move, p_value)
        score = -minimax(copy, -p_value, depth + 1, -beta, -alpha)
        return score if score >= beta

        alpha = score if score > alpha
      end

      alpha
    end

    def log(moves, move)
      puts "Turn: #{@board.turn_count}, name: #{@name}, symbol: #{@symbol}"
      puts Time.new.strftime('%H:%M:%S')
      p moves
      puts move
      puts
    end
  end
end
