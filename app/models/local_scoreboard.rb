class LocalScoreboard < ActiveRecord::Base
  attr_accessible :board, :code, :page

  MAX_PAGES = 20

  # Update all the scoreboard pages for the given local contest code.
  def self.update_for_code(code)
    code = code.upcase.strip
    1.upto(MAX_PAGES) do |page|
      board = Team.get_local_contest_scoreboard(code, page)
      return page - 1 if board[:rows].empty?
      rec = find_or_initialize_by_code_and_page(code, page)
      rec.board = board.to_json
      rec.save!
    end
    return MAX_PAGES;
  end

  # Retrieve the scoreboard page for given code and page number (1 if nil or none provided).
  # If there is no such page, return a blank scoreboard.
  def self.for_code(code, page = nil)
    page = 1 if page.nil?
    lsb = find_by_code_and_page(code.upcase, page.to_i)
    dsb = lsb ? ActiveSupport::JSON.decode(lsb.board, :symbolize_names => true) : Team.new_local_scoreboard
    dsb[:page] = page
    dsb[:page_count] = page_count(code)
    dsb
  end

  def self.page_count(code)
    where(:code => code.upcase).count
  end
end
