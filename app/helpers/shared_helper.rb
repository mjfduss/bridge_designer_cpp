require 'matrix'

module SharedHelper

  def columnize(items, n_cols)
    n_rows = (items.length + n_cols - 1) / n_cols
    Matrix.build(n_rows, n_cols) { |i, j| items[i + n_rows * j] } .to_a
  end

  def insert_html_breaks(obj)
    if obj.kind_of?(Array) then obj.join('<br>').html_safe else obj end
  end

  def sep
    @@sep ||= ('&nbsp;' * 2).html_safe
  end

  def team_review_group_list_data(groups)
    ( groups.map { |g| [g.description, g.id] } ).unshift( ['Select Group',  '-'] )
  end
end