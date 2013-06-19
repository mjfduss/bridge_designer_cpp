class CreateBests < ActiveRecord::Migration
  def change
    create_table :bests do |t|
      t.integer :team_id, :null => false
      t.integer :design_id, :null => false
      # These are de-normalized data to avoid a full join
      # of users and designs to generate each scoreboard.
      t.string  :scenario, :limit => 10, :null => true
      t.integer :score, :null => false
      t.integer :sequence, :null => false
      t.timestamps
    end
    # Search for team by name key
    add_index :teams, :name_key, :unique => true
    # Search for administrator by name
    add_index :administrators, :name, :unique => true
    # Associate members with team
    add_index :members, :team_id, :unique => false
    # Search for local contest by code
    add_index :local_contests, :code, :unique => true
    # Associate team with its local contests and guarantee uniqueness.
    add_index :affiliations, :team_id, :unique => false
    # Associate local contest with its teams
    add_index :affiliations, :local_contest_id, :unique => false
    # Find top scoring teams by scenario (for 6-char local contest) or overall (null scenario).
    add_index :bests, [:score, :sequence], :unique => false
    add_index :bests, :scenario, :unique => false
    # Find designs by hash string.
    add_index :designs, :hash_string, :unique => false
    add_index :designs, [:score, :sequence], :unique => true
    # Delete unaccepted scoreboards.
    add_index :scoreboards, [:admin_id, :status ], :unique => false
  end
end
