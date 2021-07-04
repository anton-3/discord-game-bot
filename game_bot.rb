# frozen-string-literal: true

#
# TODO:
# tic tac toe
# rock paper scissors
# hangman
# chess (eventually)

require 'discordrb'
require_relative 'discord_game'

%w[connect-4].each do |game_dir|
  require_relative "#{game_dir}/client.rb"
end

# logic for the bot client
# adds functionality from each individual game and controls running the bot
class GameBot
  CONFIG = File.foreach('config.txt').map { |line| line.split(' ').join(' ') }
  TOKEN = CONFIG[0].to_s
  CLIENT_ID = CONFIG[1].to_s
  LOG_MODE = :normal
  STATUS = 'invisible'
  HELP_DESC = 'Shows a list of available game commands'
  GAMES = [
    Connect4
  ].freeze

  def initialize
    @bot = create_bot
    @games = []
    GAMES.each do |game_module|
      game = game_module::Client.new
      @games << game
      game.add_bot(@bot)
    end
    @bot.command(:gamehelp, description: HELP_DESC, max_args: 0, aliases: [:gh]) { |msg| cmd_gamehelp(msg) }
    @bot.reaction_add { |evt| auto_delete_reactions(evt) }
    @bot.ready { on_ready }
  end

  def create_bot
    Discordrb::Commands::CommandBot.new(
      token: TOKEN,
      client_id: CLIENT_ID,
      prefix: '!',
      log_mode: LOG_MODE,
      help_command: false
    )
  end

  def on_ready
    puts 'Game Bot connected successfully'
    @bot.update_status(STATUS, '!gamehelp', nil)
  end

  def run
    at_exit { @bot.stop }
    @bot.run
  end

  private

  # TODO: make this an embed
  def cmd_gamehelp(msg)
    response = '**List of commands:**'
    @games.each do |game|
      response += game.help
    end
    msg.respond(response)
  end

  def auto_delete_reactions(evt)
    evt.message.delete_reaction(evt.user, evt.emoji.to_s) if @bot.bot_user == evt.message.author
  end
end
