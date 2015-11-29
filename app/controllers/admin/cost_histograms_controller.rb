class Admin::CostHistogramsController < Admin::ApplicationController

  layout nil

  def show
    histogram, basis = Design.cost_histogram_as_string
    if basis && basis > 0
      respond_to do |format|
        format.csv { send_data histogram, :type => 'text/csv', :filename => "cost_histogram_#{Time.now.strftime('%Y-%m-%d-%02H%02M%02S')}.csv" }
      end
    else
      render :nothing => true
    end
  end

end
