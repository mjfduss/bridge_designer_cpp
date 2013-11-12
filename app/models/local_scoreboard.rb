class LocalScoreboard < ActiveRecord::Base
  attr_accessible :board, :code, :page

  def self.create_for_code(code)
    code = code.upcase
    1.upto(20) do |page|
      board = Team.get_local_contest_scoreboard(code, page)
      break if board[:rows].empty?
      rec = find_or_initialize_by_code_and_page(code, page)
      rec.board = board.to_json
      rec.save!
    end
  end

  def self.for_code(code, page = nil)
    page = 1 if page.nil?
    get(find_by_code_and_page(code.upcase, page.to_i)) || Team.new_local_scoreboard
  end

  private

  def self.get(rec)
    return nil if rec.nil?
    ActiveSupport::JSON.decode rec.board, :symbolize_names => true
  end
end
