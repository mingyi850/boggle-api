require_relative 'games_creator.rb'

# Class which manages all game-operations and logic.
class GamesManager

  class GameError < StandardError; end
  class WordAlreadyFoundError < GameError; end
  class WordNotInDictionaryError < GameError; end
  class WordNotOnBoardError < GameError; end
  class InvalidTokenError < GameError; end
  class GameExpiredError < GameError; end
  class InvalidWordError < GameError; end

  class << self
    # Initialises dictionary words in memory for quick lookup
    def init_dictionary
      arr = IO.readlines('dictionary.txt', chomp: true).map(&:upcase)
      @dictionary = Set.new(arr)
    end

    def check_game_expired(game)
      raise GameExpiredError, 'Game has expired. Congrats' if game.expired?
    end

    def validate_game_token(game, token)
      raise InvalidTokenError, 'Invalid Token' unless game.valid_token?(token)
    end

    # Checks if a user's guess is valid and should award the user points
    def verify_word(word, game)
      word.upcase!
      raise InvalidWordError, 'Word contains invalid characters!' unless word.match(/[a-zA-Z]+/)
      raise WordNotInDictionaryError, 'Word not in dictionary!' unless @dictionary.include?(word)
      raise WordAlreadyFoundError, 'Word already found!' if game[:found_words].include?(word)
      raise WordNotOnBoardError, 'Word not on board!' unless word_on_board?(game[:board], game[:char_map], word)

      true
    end

    # Checks if the word exists on the board
    def word_on_board?(board, char_map, word)
      board_arr = board.split(', ')
      char_locations = char_map[word[0]] || []
      star_locations = char_map['*'] || []
      start_locations = char_locations + star_locations

      start_locations.each do |index|
        return true if search_for_word(board_arr, index, word, Set.new)
      end

      false
    end

    private

    # Use recursive DFS to find word in board
    def search_for_word(board, index, word, visited)
      visited.add(index)
      word = word[1..-1]

      return true if word.empty?

      return true if word_found_in_path?(board, get_up(index), word, visited.dup)
      return true if word_found_in_path?(board, get_down(index), word, visited.dup)
      return true if word_found_in_path?(board, get_left(index), word, visited.dup)
      return true if word_found_in_path?(board, get_right(index), word, visited.dup)

      false
    end

    # Checks if an index should be traversed next by the dfs algorithm
    def valid_path?(board, index, word, visited)
      !index.nil? && !visited.include?(index) && (board[index] == word[0] || board[index] == '*')
    end

    # Checks recursive function which encapsulates both validation and search
    def word_found_in_path?(board, index, word, visited)
      valid_path?(board, index, word, visited) && search_for_word(board, index, word, visited)
    end

    # Gets the index of the square above if valid
    def get_up(index)
      index < 4 ? nil : index - 4
    end

    # Gets the index of the square below if valid
    def get_down(index)
      index > 12 ? nil : index + 4
    end

    # Gets the index of the square to the left if valid
    def get_left(index)
      (index % 4).zero? ? nil : index - 1
    end

    # Gets the index of the square to the right if valid
    def get_right(index)
      (index + 1 % 4).zero? ? nil : index + 1
    end

  end
end

GamesManager.init_dictionary
