module HomesHelper

  def to_cost(score)
    number_to_currency(score * 0.01)
  end

end