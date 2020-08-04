require_relative '../services/games_manager.rb'

class Game < ApplicationRecord
  validates :board, presence: true
  validates :token, presence: true
  validates :duration, presence: true
  validates :points, presence: true

  serialize :found_words
  serialize :char_map

  def update_time_left
    self.time_left = [duration - (Time.now - created_at), 0].max
  end

  def expired?
    update_time_left
    self.time_left.zero?
  end

  def valid_token?(input_token)
    input_token == token
  end
  
  def increment_points(word)
    self.points += word.length
  end
  
  def update_found_words(word)
    found_words.add(word.upcase)
  end

  def update_game_state!(word)
    update_time_left
    update_found_words(word)
    increment_points(word)
    save!
  end
  

end
