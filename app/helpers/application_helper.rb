module ApplicationHelper
  include TablesHelper

  def self.state_select(f, m, id, i)
    sel = (i == 0 && m.category == 'u') || (i == 1 && m.category == 'n') ? m.reg_state : '--'
    return f.select id, options_for_select(TablesHelper::STATE_PAIRS, sel), {}, { :onchange => "window.state_onchange(this, #{i})"  }
  end

  def self.age_select(f, sel)
    return f.select :age, options_for_select(TablesHelper::AGE_PAIRS, sel)
  end

  def self.grade_select(f, sel)
    return f.select :grade, options_for_select(TablesHelper::GRADE_PAIRS, sel)
  end

  def self.sex_select(f, sel)
    return f.select :sex, options_for_select(TablesHelper::SEX_PAIRS, sel)
  end

  def self.hispanic_select(f, sel)
    return f.select :hispanic, options_for_select(TablesHelper::HISPANIC_PAIRS, sel)
  end

  def self.race_select(f, sel)
    return f.select :race, options_for_select(TablesHelper::RACE_PAIRS, sel)
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
