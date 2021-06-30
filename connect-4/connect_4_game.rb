# frozen-string-literal: true

# game logic
class Connect4Game
  attr_reader :p1, :p2, :board

  NUMBERS_HASH = %w[:one: :two: :three: :four: :five: :six: :seven:].freeze
  COLORS = { 1 => :red, 2 => :yellow }.freeze

  # randomize: whether or not to randomize who has the first move
  # which_ai: which users should be considered ai
  def initialize(user1, user2, randomize: false, which_ai: [false, false])
    @board = Board.new(COLORS[1], COLORS[2])
    players = [user1, user2]
    create_players(players, which_ai, randomize)
  end

  def make_move(move, value)
    @board.make_move(move, value)
  end

  def to_s
    "#{print_num_row}\n#{@board}"
  end

  def whose_turn
    # @p1 always goes first
    @board.turn_count.odd? ? @p1 : @p2
  end

  def win?
    @board.win?
  end

  def col_full?(col)
    @board.col_full?(col)
  end

  def board_full?
    @board.full?
  end

  private

  def print_num_row
    str = ''
    7.times do |num|
      str += NUMBERS_HASH[num]
    end
    str
  end

  def create_players(players, which_ai, randomize)
    order = [0, 1]
    order.shuffle! if randomize
    p_classes = []
    2.times { |num| p_classes.push(which_ai[num] ? AIPlayer : Player) }
    @p1 = p_classes[order[0]].new self, COLORS[1], players[order[0]], 1
    @p2 = p_classes[order[1]].new self, COLORS[2], players[order[1]], -1
  end
end
