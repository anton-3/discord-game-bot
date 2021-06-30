# frozen-string-literal: true

#
# TODO:
# tic tac toe
# hangman
# chess (eventually)

require 'discordrb'
require_relative 'connect-4/connect_4'

# logic for the bot client
# adds functionality from each individual game and controls running the bot
class GameBot
  CONFIG = File.foreach('config.txt').map { |line| line.split(' ').join(' ') }
  TOKEN = CONFIG[0].to_s
  CLIENT_ID = CONFIG[1].to_s
  LOG_MODE = :normal
  STATUS = 'online'
  HELP_DESC = 'Shows a list of available game commands'
  GAMES = [
    Connect4
  ].freeze

  def initialize
    @bot = create_bot
    @games = []
    GAMES.each do |game_class|
      game = game_class.new
      @games << game
      game.add_bot(@bot)
    end
    @bot.command(:gamehelp, description: HELP_DESC, max_args: 0, aliases: [:gh]) { |msg| cmd_gamehelp(msg) }
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
    response = "**List of commands:**\n"
    @games.each do |game|
      response += game.help
    end
    msg.respond(response)
  end
end
