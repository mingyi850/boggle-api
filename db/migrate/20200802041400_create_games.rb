class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.string :token
      t.integer :duration
      t.string :board
      t.integer :points
      t.string :found_words
      t.string :char_map
      t.integer :time_left

      t.timestamps
    end
  end
end
