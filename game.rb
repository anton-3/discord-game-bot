# frozen-string-literal: true

# base class for games with 2 players
class Game
  attr_reader :help

  def initialize
    @active_players = []
    @bots = []
    @help = help_str
    @bot_players_allowed = true
  end

  def add_bot(bot)
    @bots << bot
  end

  private

  def cmd_play(msg)
    return unless msg.server

    target = find_target(msg)

    if locate_player(msg.author)
      msg.respond("You're already in a game")
    elsif !target
      msg.respond("Couldn't find that person")
    elsif locate_player(target)
      msg.respond("They're already in a game")
    elsif target == msg.author
      msg.respond("You can't play yourself")
    elsif !@bot_players_allowed && (target.bot_account? || msg.author.bot_account?)
      msg.respond("Bots can't play")
    else
      start_game(msg, msg.author, target)
    end
  end

  def cmd_resign(msg)
    return unless msg.server

    player = locate_player(msg.author)
    if !player
      msg.respond("You're not in a game")
    else
      game = player.game
      end_game(game)
      win_msg = "#{player == game.p1 ? game.p2.name : game.p1.name} wins!\n"
      msg.respond("#{win_msg}#{player.user.mention} has resigned the game between #{game.p1.name} and #{game.p2.name}.")
    end
  end

  def cmd_help(msg)
    msg.respond(@help)
  end

  def reaction_add(evt)
    bot_users = @bots.map { |bot| bot.bot_user }
    return unless bot_users.include?(evt.message.author)
  end

  def start_game(*); end

  def end_game(*); end

  def help_str
    ''
  end

  # finds discord member object from a message
  def find_target(msg)
    target_name = msg.content[(msg.content.index(' ') + 1)..-1]
    msg.server.members.select { |member| member.display_name.downcase == target_name.downcase }[0]
  end

  # checks if a user should be considered an ai
  # currently you can only be an ai if you're a bot account
  def ai?(user)
    user.bot_account?
  end

  def bot_users
    @bots.map { |bot| bot.bot_user }
  end

  # returns the player object of a discord user if in @active_players
  # if not an active player, returns nil
  def locate_player(player)
    @active_players.select { |p| p.user == player }[0]
  end
end
