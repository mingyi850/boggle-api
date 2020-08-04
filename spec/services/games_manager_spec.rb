require 'rspec'
require 'rails_helper'

describe 'GamesManager' do
  game = GamesCreator.create_game( { duration: 1000, random: 'false'})
  before do

  end

  after do
    # Do nothing
  end

  describe 'GamesManager::check_game_expired' do
    it 'throws an exception when the game has expired' do
      game.created_at = Time.now - 1000
      expect {
        GamesManager.check_game_expired(game)
      }.to raise_error(GamesManager::GameExpiredError)
    end
  end

  describe 'GamesManager::validate_game_token' do
    it 'throws an exception when the issued token is not valid' do
      game.token = 'abcde'
      expect {
        GamesManager.validate_game_token(game, '12345')
      }.to raise_error(GamesManager::InvalidTokenError)
    end
  end

  describe 'GamesManager::validate_game_token' do
    it 'throws an exception when the issued token is not valid' do
      game.token = 'abcde'
      expect {
        GamesManager.validate_game_token(game, '12345')
      }.to raise_error(GamesManager::InvalidTokenError)
    end
  end

  describe 'GamesManager::verify_word' do
    it 'throws an exception if word passed contains non-alphabetic characters' do
      expect {
        GamesManager.verify_word('ab*', game)
      }.to raise_error(GamesManager::WordNotInDictionaryError)
    end

    it 'throws an exception if word passed is not in dictionary' do
      expect {
        GamesManager.verify_word('supercalibfaws', game)
      }.to raise_error(GamesManager::WordNotInDictionaryError)
    end

    it 'throws an exception if word passed is in dictionary but not on board' do
      expect {
        GamesManager.verify_word('bee', game)
      }.to raise_error(GamesManager::WordNotOnBoardError)
    end

    it 'throws an exception if word passed is in dictionary, on board but already found' do
      game.found_words.add('TAP')
      expect {
        GamesManager.verify_word('tap', game)
      }.to raise_error(GamesManager::WordAlreadyFoundError)
    end

    it 'returns true if word passed is valid' do
      expect(GamesManager.verify_word('pat', game)).to be true
    end
  end

  describe 'GamesManager::word_on_board?' do
    it 'returns true if it is possible to get given string from the board' do
      expect(GamesManager.word_on_board?(game.board, game.char_map, 'TAPESKAEOBRSDXOS')).to be true
    end
    it 'returns false if it is not possible to get given string from the board' do
      expect(GamesManager.word_on_board?(game.board, game.char_map, 'TAPESKADDBRSDXOS')).to be false
    end
  end

end