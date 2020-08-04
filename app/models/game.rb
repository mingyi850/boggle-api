require_relative '../services/games_manager.rb'

# Model class for Game entity
class Game < ApplicationRecord
  validates :board, presence: true
  validates :token, presence: true
  validates :duration, presence: true
  validates :points, presence: true
  validates :char_map, presence: true

  serialize :found_words
  serialize :char_map

  # Calculates the time left on the game
  def update_time_left
    self.time_left = [duration - (Time.now - created_at), 0].max
  end

  # Checks if a game has expired
  def expired?
    update_time_left
    time_left.zero?
  end

  # Applied on a successful PUT request to make changes and save them
  def update_game_state!(word)
    update_time_left
    update_found_words(word)
    increment_points(word)
    save!
  end

  # Checks if a provided token matches the game token
  def valid_token?(input_token)
    input_token == token
  end

  # Increase the number of points through a scoring system
  def increment_points(word)
    self.points += word.length
  end

  # Updates the list of found words in a game
  def update_found_words(word)
    found_words.add(word.upcase)
  end

end
