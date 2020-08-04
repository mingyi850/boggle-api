require 'rspec'
require 'rails_helper'
describe 'Game' do

  describe 'validations' do
    it 'is invalid without a board' do
      game = GamesCreator.create_game({duration: 1000, random: 'true'})
      game.board = nil
      expect(game).to be_invalid
    end
    it 'is invalid without a token' do
      game = GamesCreator.create_game({duration: 1000, random: 'true'})
      game.token = nil
      expect(game).to be_invalid
    end
    it 'is invalid without a duration' do
      game = GamesCreator.create_game({duration: 1000, random: 'true'})
      game.duration = nil
      expect(game).to be_invalid
    end
    it 'is invalid without points' do
      game = GamesCreator.create_game({duration: 1000, random: 'true'})
      game.points = nil
      expect(game).to be_invalid
    end
    it 'is invalid without char_map' do
      game = GamesCreator.create_game({duration: 1000, random: 'true'})
      game.char_map = nil
      expect(game).to be_invalid
    end
  end

  describe 'Game.update_time_left' do
    it 'edits the remaining time' do
      game = GamesCreator.create_game({duration: 1000, random: 'true'})
      game.created_at = Time.now
      sleep(1)
      game.update_time_left
      expect(game.time_left).to be < game.duration
    end
  end

  describe 'Game.expired?' do
    it 'check if remaining time is 0' do
      game = GamesCreator.create_game({duration: 1000, random: 'true'})
      game.created_at = Time.now - 1001
      expect(game.expired?).to be true
    end
  end

end