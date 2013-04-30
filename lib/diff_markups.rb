module DiffMarkups

  INS_TAG = '<span class="ins">'
  DEL_TAG = '<span class="del">'
  END_TAG = '</span>'

  def self.getMarkup(a, b)
    as, bs = a.to_s.split(' '), b.to_s.split(' ')
    out = []
    action = '='
    Diff::LCS::traverse_sequences(as, bs) do |e|
      if e.action == action
        out << CGI::escapeHTML(e.action == '-' ? e.old_element : e.new_element)
      else
        out[-1] << END_TAG unless action == '='
        case e.action
          when '+'
            out << "#{INS_TAG}#{CGI::escapeHTML(e.new_element)}"
          when '-'
            out << "#{DEL_TAG}#{CGI::escapeHTML(e.old_element)}"
          else
            out << CGI::escapeHTML(e.new_element)
        end
        action = e.action
      end
    end
    out[-1] << END_TAG unless action == '='
    out.join(' ').html_safe
  end

  def self.deep_length(lst)
    lst.is_a?(Array) ? ( lst.inject(0) { |sum, item| sum += deep_length(item) } ) : 1;
  end

  # Args a and b are arrays of 1 or 2 strings.  Produce an array of 1
  # or 2 marked up strings depicting the diff that produces fewest edits.
  def self.getMarkedUpPair(a, b)
    if a.length == b.length
      a.zip(b).map {|p| getMarkup(*p)}
    elsif a.length == 2 && b.length == 1
      deep_length(Diff::LCS::diff(a[0], b[0])) <= deep_length(Diff::LCS::diff(a[1], b[0])) ?
        [ getMarkup(a[0], b[0]), "#{DEL_TAG}#{a[1]}#{END_TAG}" ] :
        [ "#{DEL_TAG}#{a[0]}#{END_TAG}", getMarkup(a[1], b[0]) ]
    elsif a.length == 1 && b.length == 2
      deep_length(Diff::LCS::diff(a[0], b[0])) <= deep_length(Diff::LCS::diff(a[0], b[1])) ?
        [ getMarkup(a[0], b[0]), "#{DEL_TAG}#{a[1]}#{END_TAG}" ] :
        [ "#{DEL_TAG}#{b[0]}#{END_TAG}", getMarkup(a[0], b[1]) ]
    end
  end
end