require 'WPBDC/WPBDC'

module WPBDC

  # Publish the contest year for the rest of the system.  This allows us
  # to decouple the judge contest year from the system during transition periods.
  CONTEST_YEAR = 2015

  # A useful constant for finding test data.
  PATH = File.dirname(__FILE__)

  ## Helper to extract scenario id from a complete 6-character local contest code
  # @param [String] code local contest code
  # @return [String] scenario id, a 10-digit number or nil if the given code was not a valid one
  def self.local_contest_code_to_id(code)
    code.length == 6 ? local_contest_number_to_id(code[-3..-1]) : nil
  end

end
