class Scoreboard < ActiveRecord::Base

  attr_accessible :admin_id, :board, :category, :status

  default_scope order('created_at ASC')

  # Get the current scoreboard.  If empty_p is true, a null
  # return is replaced with an empty scoreboard structure.
  def self.get_current(category, empty_p = true)
    sb = get(where("category = ? AND status = 'p'", category).last)
    sb ||= Team.get_scoreboard(category) if empty_p
    sb
  end

  # Get a scoreboard given its AR id.  If empty_p is true, a null
  # return is replaced with an empty scoreboard structure.
  def self.get_by_id(id, category, empty_p = true)
    sb = get(find(id))
    sb ||= Team.get_scoreboard(category) if empty_p
    sb
  end

  private

  def self.get(sb)
    return nil if sb.nil?
    ActiveSupport::JSON.decode sb.board, :symbolize_names => true
  end
end
