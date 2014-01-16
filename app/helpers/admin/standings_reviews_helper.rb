module Admin::StandingsReviewsHelper

  def row_height(row)
    row.map { |key, val| val.kind_of?(Array) ? val.length : 1 }.max;
  end

end
