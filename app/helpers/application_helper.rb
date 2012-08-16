include ActionView::Helpers::FormOptionsHelper

module ApplicationHelper

  @@pairs = 
    [
     ['--Select Here--', '0']
    ]

  @@options =  options_for_select(@@pairs, '0')

  def self.state_select(f, id)
    return f.select id, @@options
  end

end
