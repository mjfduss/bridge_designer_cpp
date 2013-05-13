require 'matrix'

module SharedHelper

  def columnize(items, n_cols)
    n_rows = (items.length + n_cols - 1) / n_cols
    Matrix.build(n_rows, n_cols) { |i, j| items[i + n_rows * j] } .to_a
  end

  def htmlify(obj)
    case obj
      when String
        obj
      when Array
        obj.join(', ').html_safe
      when Design
        html = image_tag url_for(:controller => 'admin/designs', :action => :show, :id => obj.id), :class => :sketch
        html << " [#{link_to 'Analysis', { :controller => 'admin/designs', :action => :show, :id => obj.id}, {:class => 'review', :target => 'analysis'}}]".html_safe
        html << " [#{link_to 'Bridge', {:controller => 'admin/designs', :action => :show, :id => obj.id, :format => :bdc}, {:class => 'review'}}]".html_safe
    end
  end

  def sep
    @@sep ||= ('&nbsp;' * 2).html_safe
  end

  def team_review_group_list_data(groups)
    pairs = groups ? groups.map { |g| [g.description, g.id] } : []
    pairs.unshift( ['Select Group',  '-'] )
  end
end