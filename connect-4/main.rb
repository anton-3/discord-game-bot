# frozen-string-literal: true

require 'discordrb'
require_relative 'connect_4_bot'
require_relative 'connect_4'
require_relative 'board'
require_relative 'player'
require_relative 'ai_player'

Connect4Bot.new.run
