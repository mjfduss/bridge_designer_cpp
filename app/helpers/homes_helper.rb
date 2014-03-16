module HomesHelper

  def to_cost(score)
    number_to_currency(score * 0.01)
  end

  def certificate_link(c)
    lc = c.local_contest
    name = if lc
             "#{lc.description} (#{lc.code})"
           else
             "#{WPBDC::CONTEST_YEAR} Qualifying Round"
           end
    link_to name, certificate_path(c, :format => :pdf), :target => "_blank"
  end

end