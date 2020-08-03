class GamesCreator

  class GameCreationError < StandardError; end
  class InvalidBoardError < GameCreationError; end

  class << self

    def create_game(game_params, params)
      game = Game.new(game_params)
      game.time_left = params[:duration]
      game.board = generate_board(params)
      game.token = generate_token
      game.points = 0
      game.found_words = Set.new
      game.char_map = get_char_map(game.board)
      game
    end

    def generate_random_board
      vowels = %w[A E I O U *]
      range = [*'A'..'Z', '*']
      merged = Array.new(12).map{ range.sample } + Array.new(4).map{ vowels.sample }
      merged.shuffle!.join(', ')
    end

    def generate_default_board
      IO.read('test_board.txt').chomp("\n").upcase
    end

    def generate_board(params)
      return generate_random_board if params[:random] == 'true'
      return generate_default_board if params[:board].nil?

      raise InvalidBoardError unless valid_board?(params[:board])

      params[:board].upcase
    end

    def valid_board?(board)
      board_arr = get_board_arr(board.upcase)
      correct_length = board_arr.length == 16
      valid_chars_only = board_arr.map{ |val| val.match?(/\A[A-Z\*]\z/) }.all?

      correct_length && valid_chars_only
    end

    def get_board_arr(board)
      board.split(', ')
    end

    def get_char_map(board)
      char_map = {}
      get_board_arr(board).each_with_index do |char, index|
        if char_map[char].nil?
          char_map[char] = [index]
        else
          char_map[char].append(index)
        end
      end
      char_map
    end

    def generate_token
      range = [*'a'..'z',*'0'..'9']
      Array.new(32).map{range.sample}.join()
    end
  end
end