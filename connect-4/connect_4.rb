# frozen-string-literal: true

require_relative '../discord_game'
require_relative 'connect_4_game'
require_relative 'board'
require_relative 'player'
require_relative 'ai_player'

# logic for interacting with the game through the discord bot client
class Connect4 < DiscordGame
  attr_reader :help

  GAME_NAME = 'Connect 4'
  BOTS_ALLOWED = true
  RANDOM_STARTING_PLAYER = true
  NUMBER_CODES = %w[1⃣ 2⃣ 3⃣ 4⃣ 5⃣ 6⃣ 7⃣].freeze
  COMMANDS = {
    play: 'Start a game against someone',
    move: 'Make a move during a game',
    resign: "Resign the game you're currently playing",
    help: 'Shows a list of available Connect 4 commands'
  }.freeze
  # AI level 1: completely random moves
  # AI level 2: takes and blocks immediate wins, otherwise random
  # AI level 3: minimax algorithm
  AI_LEVEL = 3

  def add_bot(bot)
    super
    bot.command(:c4play, description: COMMANDS[:play], min_args: 1, aliases: [:c4p]) { |msg| cmd_play(msg) }
    bot.command(:c4move, description: COMMANDS[:move], min_args: 1, aliases: [:c4m]) { |msg| cmd_move(msg) }
    bot.command(:c4resign, description: COMMANDS[:resign], max_args: 0, aliases: [:c4r]) { |msg| cmd_resign(msg) }
    bot.command(:c4help, description: COMMANDS[:help], max_args: 0, aliases: [:c4h]) { |msg| cmd_help(msg) }
    bot.reaction_add { |evt| reaction_add(evt) }
  end

  private

  def cmd_play(msg)
    super
  end

  def cmd_move(msg)
    return unless msg.server

    move = msg.content.split[1].to_i - 1
    # get the Player object for the author so we can figure out which game it is
    player = locate_player(msg.author)
    if !player
      msg.respond("You're not in a game")
    elsif move.negative? || move.digits.count > 1 || move > 6 # between 0 and 6
      msg.respond('Invalid input')
    else
      game = player.game
      if game.whose_turn != player
        msg.respond('Not your turn')
      elsif !game.legal_move?(move)
        msg.respond('Illegal move')
      else
        player.make_move(move)
        handle_move(player, msg.channel)
      end
    end
  end

  def cmd_resign(msg)
    super
  end

  def cmd_help(msg)
    super
  end

  def reaction_add(evt)
    return unless bot_users.include?(evt.message.author) && evt.message.content[0, GAME_NAME.length] == GAME_NAME
    return unless evt.message.reactions.length == 7 && NUMBER_CODES.include?(evt.emoji.to_s)

    user_id = evt.message.content.split("\n")[1][2, 18].to_i
    return unless evt.user.id == user_id

    move = NUMBER_CODES.index(evt.emoji.to_s)
    player = locate_player(evt.user)
    return unless player

    game = player.game
    return if game.whose_turn != player || !game.legal_move?(move)

    player.make_move(move)
    handle_move(player, evt.channel)
  end

  def help_str
    str = "\n*Connect 4 commands:*"
    COMMANDS.each do |name, desc|
      str += case name
             when :play
               "\n- *!c4play <person's name>:* #{desc}"
             when :move
               "\n- *!c4move <column>:* #{desc} (can also use reactions to make moves)"
             else
               "\n- *!c4#{name}:* #{desc}"
             end
    end
    str
  end

  def start_game(msg, user1, user2)
    which_ai = [ai?(user1), ai?(user2)]
    game = Connect4Game.new user1, user2, randomize: RANDOM_STARTING_PLAYER, which_ai: which_ai
    puts "#{Time.new.strftime('%H:%M:%S')} Connect 4 game between #{game.p1.name} and #{game.p2.name} has started"
    @active_players.push(game.p1, game.p2)
    display_turn(game, msg.channel)
    handle_ai(game.whose_turn, msg.channel)
  end

  def end_game(game)
    puts "#{Time.new.strftime('%H:%M:%S')} Connect 4 game between #{game.p1.name} and #{game.p2.name} has ended"
    @active_players.delete(game.p1)
    @active_players.delete(game.p2)
  end

  def handle_move(player, channel)
    game = player.game
    if game.win?
      end_game(game)
      channel.send("#{player.name} wins!\n\n#{game}")
    elsif game.board_full?
      end_game(game)
      channel.send("Tie!\n\n#{game}")
    else
      display_turn(game, channel)
      handle_ai(game.whose_turn, channel)
    end
  end

  def handle_ai(ai_player, channel)
    return unless ai?(ai_player.user)

    sleep 1
    move = case AI_LEVEL
           when 1
             ai_player.find_random_move
           when 2
             ai_player.find_decent_move
           when 3
             ai_player.find_best_move
           end

    return unless @active_players.include?(ai_player) # opponent could've resigned while AI was thinking of a move

    ai_player.make_move(move)
    handle_move(ai_player, channel)
  end

  def display_turn(game, channel)
    player = game.whose_turn
    color = ":#{player.color}_circle:"
    # 'Connect 4' needs to be at the beginning of the message
    msg = channel.send("Connect 4\n#{player.user.mention}'s turn: #{color}\n\n#{game}")
    add_reactions(msg) unless player.is_a?(AIPlayer)
  end

  def add_reactions(msg)
    7.times do |num|
      msg.react(NUMBER_CODES[num])
    end
  end
end
