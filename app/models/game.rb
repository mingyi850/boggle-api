
class Game < ApplicationRecord
  validates :board, presence: true
  validates :token, presence: true
  validates :duration, presence: true
  validates :points, presence: true

  serialize :found_words
  serialize :char_map


end
