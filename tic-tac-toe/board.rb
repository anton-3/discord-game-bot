# frozen-string-literal: true

module TicTacToe
  # logic for all game boards
  class Board
    attr_reader :turn_count, :contents, :legal_moves

    EMOJIS = { x: ':regional_indicator_x:', o: ':o2:', empty: ':white_large_square:' }.freeze

    def initialize(p1_symbol, p2_symbol)
      @turn_count = 1
      @symbols = { 1 => p1_symbol, -1 => p2_symbol }
      @legal_moves = (0..8).to_a
      @contents = Array.new(9, 0) # board stored as array of 9 integers, 0 means empty
    end

    def move(col, value)
      # assumes the move is legal (column isn't full)
      # player 1's move is stored as 1, player 2's stored as -1
      @contents[col] = value
      @turn_count += 1
      @legal_moves.delete(col)
    end

    def to_s
      str = ''
      @contents.each_with_index do |value, idx|
        str += value.zero? ? EMOJIS[:empty] : EMOJIS[@symbols[value]]
        str += "\n" if [2, 5].include?(idx)
      end
      str
    end

    def win?
      lines = rows + columns + diagonals
      lines.reduce(false) do |memo, line|
        memo || three_in_line?(line)
      end
    end

    def full?
      !@contents.include?(0)
    end

    private

    def rows
      row_arys = []
      3.times do |num|
        row_idx = num * 3
        row_arys.push(@contents[row_idx, 3])
      end
      row_arys
    end

    def columns
      col_arys = []
      3.times do |num|
        col_arys.push(@contents.values_at(num, num + 3, num + 6))
      end
      col_arys
    end

    def diagonals
      [@contents.values_at(0, 4, 8), @contents.values_at(2, 4, 6)]
    end

    # checks if a line has three of the same move in it
    def three_in_line?(line)
      line.include?(0) ? false : line.uniq.length == 1
    end
  end
end
