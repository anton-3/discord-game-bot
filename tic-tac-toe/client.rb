# frozen-string-literal: true

require_relative '../discord_game'
require_relative 'game'
require_relative 'board'
require_relative 'player'
require_relative 'ai_player'

module TicTacToe
  # logic for interacting with the game through the discord bot client
  class Client < DiscordGame
    attr_reader :help

    EMOJIS = { x: ':regional_indicator_x:', o: ':o2:' }.freeze
    BOTS_ALLOWED = false
    RANDOM_STARTING_PLAYER = true
    NUMBER_CODES = %w[1⃣ 2⃣ 3⃣ 4⃣ 5⃣ 6⃣ 7⃣ 8⃣ 9⃣].freeze
    COMMANDS = {
      play: 'Start a game against someone',
      move: 'Make a move during a game',
      resign: "Resign the game you're currently playing",
      help: 'Shows a list of available Tic Tac Toe commands'
    }.freeze

    def add_bot(bot)
      super
      bot.command(:tttplay, description: COMMANDS[:play], min_args: 1, aliases: [:tttp]) { |msg| cmd_play(msg) }
      bot.command(:tttmove, description: COMMANDS[:move], min_args: 1, aliases: [:tttm]) { |msg| cmd_move(msg) }
      bot.command(:tttresign, description: COMMANDS[:resign], max_args: 0, aliases: [:tttr]) { |msg| cmd_resign(msg) }
      bot.command(:ttthelp, description: COMMANDS[:help], max_args: 0, aliases: [:ttth]) { |msg| cmd_help(msg) }
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
      elsif move.negative? || move.digits.count > 1 || move > 8 # between 0 and 8
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
      msg.respond(@help)
    end

    def reaction_add(evt)
      msg_ids = @game_msg_ids.values.reduce { |memo, ary| memo + ary }
      return unless !msg_ids.nil? && msg_ids.include?(evt.message.id)

      previous_msg = evt.channel.message(msg_ids[msg_ids.index(evt.message.id) - 1])
      user_id = previous_msg.content[2, 18].to_i
      return unless evt.user.id == user_id && NUMBER_CODES.include?(evt.emoji.to_s)

      move = NUMBER_CODES.index(evt.emoji.to_s)
      player = locate_player(evt.user)
      return unless player

      game = player.game
      legal_move_count = game.board.legal_moves.length
      return if game.whose_turn != player || !game.legal_move?(move) || evt.message.reactions.length < legal_move_count

      player.make_move(move)
      handle_move(player, evt.channel)
    end

    def help_str
      str = "\n*Tic Tac Toe commands:*"
      COMMANDS.each do |name, desc|
        str += case name
               when :play
                 "\n- *!tttplay <person's name>:* #{desc}"
               when :move
                 "\n- *!tttmove <square>:* #{desc} (can also use reactions to make moves)"
               else
                 "\n- *!ttt#{name}:* #{desc}"
               end
      end
      str
    end

    def start_game(msg, user1, user2)
      which_ai = [ai?(user1), ai?(user2)]
      game = TicTacToe::Game.new user1, user2, randomize: RANDOM_STARTING_PLAYER, which_ai: which_ai
      @game_msg_ids[game] = []
      puts "#{Time.new.strftime('%H:%M:%S')} Tic Tac Toe game between #{game.p1.name} and #{game.p2.name} has started"
      @active_players.push(game.p1, game.p2)
      display_turn(game, msg.channel)
      handle_ai(game.whose_turn, msg.channel)
    end

    def end_game(game)
      puts "#{Time.new.strftime('%H:%M:%S')} Tic Tac Toe game between #{game.p1.name} and #{game.p2.name} has ended"
      @active_players.delete(game.p1)
      @active_players.delete(game.p2)
      @game_msg_ids.delete(game) if @active_players.empty?
    end

    def handle_move(player, channel)
      game = player.game
      if game.win?
        end_game(game)
        channel.send_multiple(["#{player.name} wins!\n", game.to_s])
      elsif game.board_full?
        end_game(game)
        channel.send_multiple(["Tie!\n", game.to_s])
      else
        display_turn(game, channel)
        handle_ai(game.whose_turn, channel)
      end
    end

    def handle_ai(ai_player, channel)
      return unless ai?(ai_player.user)

      sleep 1
      move = ai_player.find_best_move

      return unless @active_players.include?(ai_player) # opponent could've resigned while AI was thinking of a move

      ai_player.make_move(move)
      handle_move(ai_player, channel)
    end

    def display_turn(game, channel)
      player = game.whose_turn
      @game_msg_ids[game] << channel.send("#{player.user.mention}'s turn: #{EMOJIS[player.symbol]}").id
      msg = channel.send(game.to_s)
      add_reactions(msg, game) unless player.is_a?(AIPlayer)
    end

    def add_reactions(msg, game)
      @game_msg_ids[game] << msg.id
      game.board.legal_moves.each do |move|
        msg.react(NUMBER_CODES[move]) # only reacts with the remaining legal moves
      end
    end
  end
end
