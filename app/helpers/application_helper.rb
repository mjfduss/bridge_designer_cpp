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
    return '<a onmouseout="return show(\'\')" href="javascript:alert(\'' + msg + \
      '\')" onmouseover="return show(\'' + msg + \
      '\')"><img class="oops" alt="Oops: ' + msg + \
      '" title="' + msg + \
      '" src="/assets/oops.gif"></a>'
  end

  def oops_on(obj, tag)
    return obj.errors.include?(tag) ? oops(obj.errors[tag][0]) : ''
  end

end
