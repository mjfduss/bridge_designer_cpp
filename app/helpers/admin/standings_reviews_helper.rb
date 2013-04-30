module Admin::StandingsReviewsHelper

  def row_height(row)
    row.map { |i| i.kind_of?(Array) ? i.length : 1 }.max;
  end

end
