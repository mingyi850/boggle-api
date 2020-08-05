require 'rspec'
require 'rails_helper'
describe 'GamesCreator' do

  describe 'GamesCreator.create_game' do
    it 'creates a valid game entry' do
      expect(GamesCreator.create_game({duration: 1000, random: 'true'})).to be_valid
    end
  end

  describe 'GamesCreator.generate_board' do
    it 'creates a random board when given random=true param' do
      expect(GamesCreator).to receive(:generate_random_board)
      GamesCreator.generate_board({duration: 1000, random: 'true'})
    end

    it 'uses test board when given random=false but board is not provided' do
      expect(GamesCreator).to receive(:generate_default_board)
      GamesCreator.generate_board({random: 'false'})
    end

    it 'raises an error when supplied board is of bad length' do
      invalid_board = 'a, b, b, d, e'
      expect {
        GamesCreator.generate_board({random: 'false', board: invalid_board})
      }.to raise_error(GamesCreator::InvalidBoardError)
    end

    it 'raises an error when supplied board contains invalid characters' do
      invalid_board = 'a, b, b, d, e, f, g, h, i, j ,k, l, l, 2, 3, @'
      expect {
        GamesCreator.generate_board({random: 'false', board: invalid_board})
      }.to raise_error(GamesCreator::InvalidBoardError)
    end
    it 'returns supplied board in uppercase if it is valid' do
      valid_board = 'a, b, b, d, e, f, g, h, i, j, k, l, l, *, *, p'
      expect(GamesCreator.generate_board({random: 'false', board: valid_board})).to eq valid_board.upcase
    end
  end

  describe 'GamesCreator::get_char_map' do
    valid_board = 'a, b, b, d, e, f, g, h, i, j, k, l, l, *, *, p'
    it 'creates a mapping of character to index list' do
      char_map = GamesCreator.get_char_map(valid_board)
      expect(char_map['e']).to eq [4]
      expect(char_map['*'].length).to eq 2
    end
  end

end