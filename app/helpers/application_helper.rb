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

  def oops(msg)
    return '<img class="oops" alt="Oops icon" title="' + msg + '" src="/assets/oops.gif">'
  end
end
