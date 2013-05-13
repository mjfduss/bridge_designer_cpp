require 'WPBDC/WPBDC'

module WPBDC

  ## Helper to extract scenario id from a complete 6-character local contest code
  # @param [String] code local contest code
  # @return [String] scenario id, a 10-digit number or nil if the given code was not a correct one
  def self.local_contest_code_to_id(code)
    code.length == 6 && local_contest_number_to_id(code[-3..-1])
  end
end