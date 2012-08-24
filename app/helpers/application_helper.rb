
module ApplicationHelper
  #include ActionView::Helpers::FormOptionsHelper
  #include ActionView::Helpers::JavaScriptHelper

  @@pairs = 
    [
     ['--------Select Here--------', '--'],
     ["Alabama", "AL"],
     ["Alaska", "AK"],
     ["American Samoa", "AS"],
     ["Arizona", "AZ"],
     ["Arkansas", "AR"],
     ["California", "CA"],
     ["Colorado", "CO"],
     ["Connecticut", "CT"],
     ["Delaware", "DE"],
     ["District of Columbia", "DC"],
     ["Fed Sts of Micronesia", "FM"],
     ["Florida", "FL"],
     ["Georgia", "GA"],
     ["Guam", "GU"],
     ["Hawaii", "HI"],
     ["Idaho", "ID"],
     ["Illinois", "IL"],
     ["Indiana", "IN"],
     ["Iowa", "IA"],
     ["Kansas", "KS"],
     ["Kentucky", "KY"],
     ["Louisiana", "LA"],
     ["Maine", "ME"],
     ["Marshall Islands", "MH"],
     ["Maryland", "MD"],
     ["Massachusetts", "MA"],
     ["Michigan", "MI"],
     ["Minnesota", "MN"],
     ["Mississippi", "MS"],
     ["Missouri", "MO"],
     ["Montana", "MT"],
     ["Nebraska", "NE"],
     ["Nevada", "NV"],
     ["New Hampshire", "NH"],
     ["New Jersey", "NJ"],
     ["New Mexico", "NM"],
     ["New York", "NY"],
     ["North Carolina", "NC"],
     ["North Dakota", "ND"],
     ["Northern Mariana Is", "MP"],
     ["Ohio", "OH"],
     ["Oklahoma", "OK"],
     ["Oregon", "OR"],
     ["Palau", "PW"],
     ["Pennsylvania", "PA"],
     ["Puerto Rico", "PR"],
     ["Rhode Island", "RI"],
     ["South Carolina", "SC"],
     ["South Dakota", "SD"],
     ["Tennessee", "TN"],
     ["Texas", "TX"],
     ["Utah", "UT"],
     ["Vermont", "VT"],
     ["Virgin Islands", "VI"],
     ["Virginia", "VA"],
     ["Washington", "WA"],
     ["West Virginia", "WV"],
     ["Wisconsin", "WI"],
     ["Wyoming", "WY"],
    ]

  @@abbrevs = Hash[ @@pairs.map{ |p| [p[1], true] } ]

  def self.state_select(f, m, id, i)
    sel = (i == 0 && m.category == 'u') || (i == 1 && m.category == 'n') ? m.reg_state : '--'
    return f.select id, options_for_select(@@pairs, sel), {}, { :onchange => "window.state_onchange(this, #{i})"  }
  end

  def self.valid_state? (s)
    @@abbrevs[s] == true
  end

  def oops(msg)
    js_msg = escape_javascript(msg)
    return '<a onmouseout="return window.show(\'\')" href="javascript:alert(\'' + js_msg + \
      '\')" onmouseover="return window.show(\'' + js_msg + \
      '\')"><img class="oops" alt="Oops: ' + msg + \
      '" title="' + msg + \
      '" src="/assets/oops.gif"></a>'
  end

  def oops_on(obj, tags)
    tags = [tags] unless tags.is_a?(Array)
    tags.each{ |tag| 
      return oops(obj.errors.full_message(tag, obj.errors[tag][0])) \
        if obj.errors.include?(tag) 
    }
    return ''
  end

end
