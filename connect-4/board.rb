# frozen-string-literal: true

# logic for all game boards
class Board
  attr_reader :turn_count, :contents, :legal_moves

  def initialize(p1_color, p2_color)
    @turn_count = 1
    @colors = { 1 => p1_color, -1 => p2_color }
    @legal_moves = (0..6).to_a
    @contents = []
    7.times { @contents.push(Array.new(6, 0)) }
  end

  def make_move(move, value)
    # assumes the move is legal (column isn't full)
    # player 1's move is stored as 1, player 2's stored as -1
    col_arr = @contents[move]
    col_arr[col_arr.index(0)] = value
    @turn_count += 1
    update_legal_moves
  end

  def to_s
    str = ''
    6.times do |num|
      row(num).each do |x|
        str += x.zero? ? ':blue_circle:' : ":#{@colors[x]}_circle:"
      end
      str += "\n"
    end
    str
  end

  def win?
    four_in_row? || four_in_col? || four_in_diag?
  end

  def col_full?(col)
    !@contents[col].include?(0)
  end

  def full?
    @contents.reduce(true) do |memo, col|
      memo && !col.include?(0)
    end
  end

  # returns array of all rows
  def rows
    arr = []
    @contents[0].length.times do |num|
      arr.push(row(num))
    end
    arr
  end

  # returns array of all diagonals
  def diagonals
    find_up_diags + find_down_diags
  end

  private

  # rows counted top to bottom, starts at 0
  def row(num, contents = @contents)
    index = contents[0].length - 1 - num
    row_arr = []
    contents.each do |col|
      row_arr.push(col[index])
    end
    row_arr
  end

  # check if there's any sequence of four in any row on the board
  def four_in_row?
    output = false
    6.times do |num|
      output ||= four_in_ary?(row(num + 1))
    end
    output
  end

  # check if there's any sequence of four in any column on the board
  def four_in_col?
    @contents.reduce(false) do |memo, col|
      memo || four_in_ary?(col)
    end
  end

  # check if there's any sequence of four in any diagonal on the board
  def four_in_diag?
    diags = find_up_diags + find_down_diags
    diags.reduce(false) do |memo, diag|
      memo || four_in_ary?(diag)
    end
  end

  # check if there's any sequence of four in an array
  def four_in_ary?(array)
    longest_length = current_length = 1
    array.each_with_index do |el, i|
      next if i.zero?

      !el.zero? && el == array[i - 1] ? current_length += 1 : current_length = 1
      longest_length = current_length if current_length > longest_length
    end
    longest_length >= 4
  end

  def find_up_diags
    copy = Marshal.load(Marshal.dump(@contents)) # deep copy
    # shift each column down proportionally to make the diagonals line up
    copy.each_with_index do |col, i|
      (6 - i).times { col.unshift(nil) }
      i.times { col.push(nil) }
    end
    make_diags(copy)
  end

  def find_down_diags
    copy = Marshal.load(Marshal.dump(@contents)) # deep copy
    # shift each column up proportionally to make the diagonals line up
    copy.each_with_index do |col, i|
      i.times { col.unshift(nil) }
      (6 - i).times { col.push(nil) }
    end
    make_diags(copy)
  end

  def make_diags(ary)
    diags = []
    ary[0].length.times do |num|
      diag = row(num, ary)
      diag.delete(nil)
      diags.push(diag)
    end
    diags
  end

  def update_legal_moves
    7.times do |move|
      @legal_moves.delete(move) if col_full?(move)
    end
  end
end
