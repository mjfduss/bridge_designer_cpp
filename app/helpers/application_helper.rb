include ActionView::Helpers::FormOptionsHelper

module ApplicationHelper

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

  @@options =  options_for_select(@@pairs, '--')

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

  def oops_on(obj, tags)
    tags = [tags] unless tags.is_a?(Array)
    tags.each{ |tag| 
      return oops(obj.errors.full_message(tag, obj.errors[tag][0])) \
        if obj.errors.include?(tag) 
    }
    return ''
  end

end
