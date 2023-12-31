include ActionView::Helpers::FormOptionsHelper
require 'matrix'

module ApplicationHelper
  include TablesHelper

  def state_selected(m, ch)
    m.category == ch ? m.reg_state : '-'
  end

  def age_selected(m, ch)
    m.category == ch ? m.age : '-'
  end

  def grade_selected(m, ch)
    m.category == ch ? m.grade : '-'
  end

  def school_state_select(f, m)
    f.select :school_state, options_for_select(TablesHelper::STATE_PAIRS, state_selected(m, 'u')),
      {}, { :id => "school_state", :onchange => "window.res_list_change(this)"  }
  end

  def res_state_select(f, m)
    f.select :res_state, options_for_select(TablesHelper::STATE_PAIRS, state_selected(m, 'n')),
      {}, {  :id => "res_state", :onchange => "window.nonres_list_change(this)"  }
  end

  def res_age_select(f, m)
    f.select :res_age, options_for_select(TablesHelper::AGE_PAIRS, age_selected(m, 'u')),
      {}, { :id => "res_age", :onchange => "window.res_list_change(this)"  }
  end

  def nonres_age_select(f, m)
    f.select :nonres_age, options_for_select(TablesHelper::AGE_PAIRS, age_selected(m, 'n')),
      {}, { :id => "nonres_age", :onchange => "window.nonres_list_change(this)"  }
  end

  def res_grade_select(f, m)
    f.select :res_grade, options_for_select(TablesHelper::GRADE_PAIRS, grade_selected(m, 'u')),
      {}, { :id => "res_grade", :onchange => "window.res_list_change(this)"  }
  end

  def nonres_grade_select(f, m)
    f.select :nonres_grade, options_for_select(TablesHelper::GRADE_PAIRS, grade_selected(m, 'n')),
      {}, { :id => "nonres_grade", :onchange => "window.nonres_list_change(this)"  }
  end

  def age_select(f, sel)
    f.select :age, options_for_select(TablesHelper::AGE_PAIRS, sel || '-')
  end

  def grade_select(f, sel)
    f.select :grade, options_for_select(TablesHelper::GRADE_PAIRS, sel || '-')
  end

  def sex_select(f, sel)
    f.select :sex, options_for_select(TablesHelper::SEX_PAIRS, sel || '-')
  end

  def hispanic_select(f, sel)
    f.select :hispanic, options_for_select(TablesHelper::HISPANIC_PAIRS, sel || '-')
  end

  def race_select(f, sel)
    f.select :race, options_for_select(TablesHelper::RACE_PAIRS, sel || '-')
  end

  def oops(msg)
    js_msg = escape_javascript(msg)
    '<a onmouseout="return window.show(\'\')" href="javascript:alert(\'' + js_msg + \
      '\')" onmouseover="return window.show(\'' + js_msg + \
      '\')"><img class="oops" alt="Oops: ' + msg + \
      '" title="' + msg + \
      '" src="/assets/oops.gif"></a>'
  end

  def oops_on(obj, tags)
    tags = [tags] unless tags.is_a?(Array)
    tags.each{ |tag| 
      return oops(obj.errors.full_message(tag, obj.errors[tag][0])) if obj.errors.include?(tag) 
    }
    ''
  end

  def local_contest_list(team)
    team.local_contests.map {|c| c.code}.join(', ')
  end

  def columnize(items, n_cols)
    n_rows = (items.length + n_cols - 1) / n_cols
    Matrix.build(n_rows, n_cols) { |i, j| items[i + n_rows * j] } .to_a
  end

  def htmlify(obj)
    case obj
      when ActiveSupport::TimeWithZone
        obj.to_s(:nice)
      when Array
        obj.join(', ').html_safe
      when Design
        html = image_tag url_for(:controller => 'admin/designs', :action => :show, :id => obj.id, :format => :png), :class => :sketch
        html << " [#{link_to 'Analysis', { :controller => 'admin/designs', :action => :show, :id => obj.id, :format => :html}, {:class => 'review', :target => 'analysis'}}]".html_safe
        html << " [#{link_to 'Bridge', {:controller => 'admin/designs', :action => :show, :id => obj.id, :format => :bdc}, {:class => 'review'}}]".html_safe
      else
        obj
    end
  end

  def sep
    @@sep ||= ('&nbsp;' * 2).html_safe
  end

  def team_review_group_list_data(groups)
    pairs = groups ? groups.map { |g| [g.description, g.id] } : []
    pairs.unshift( ['No group selected',  '-'] )
  end
end
