class Design < ActiveRecord::Base
  include ActiveModel::Validations

  attr_accessible :score, :sequence, :scenario, :hash_string, :bridge

  belongs_to :team
  has_many :bests # Actually has_0-2: can be best of one national and one local contest
  after_save :update_bests

  validates :bridge, :presence => true
  validates :scenario, :length => { :is => 10 }
  validates :sequence, :uniqueness => true
  validates :hash_string, :length => { :is => 40 }
  validates :score, :numericality => true

  class ImprovementValidator < ActiveModel::Validator
    def validate(design)
      unless design.improves_on?(Design.find_by_team_id_and_scenario(design.team.id, design.scenario))
        design.errors[:score] << 'A teammate already improved your design for this scenario'
      end
    end
  end

  validates_with ImprovementValidator

  def self.ordered_by_standing
    order("score ASC, sequence ASC")
  end

  def sketch(width, height)
    WPBDC.sketch(bridge, width, height)
  end

  def analysis_table
    WPBDC.analysis_table(bridge)
  end

  def improves_on?(other)
    other.nil? || score < other.score || (score == other.score && sequence < other.sequence)
  end

  private

  def update_bests

    # Validator ensured this really is a new best for scenario, so okay to save.
    save_best(Best.find_or_initialize_by_team_id_and_scenario(team.id, scenario))

    # Overall best is not to be affected by the semifinal entry.
    if scenario != WPBDC::SEMIFINAL_SCENARIO_ID

      # For the best overall, look up or make a new record.
      best_overall = Best.find_or_initialize_by_team_id_and_scenario(team.id, nil)

      # Save the new record or updated values if score is an improvement.
      if best_overall.new_record? || score < best_overall.score
        save_best(best_overall)
      end
    end
    true
  end

  def save_best(best)
    best.design = self
    best.score = score
    best.sequence = sequence
    best.save!
  end
end