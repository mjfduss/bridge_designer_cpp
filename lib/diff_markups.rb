module DiffMarkups

  INS_TAG = '<span class="ins">'
  DEL_TAG = '<span class="del">'
  END_TAG = '</span>'

  # @param [String] team_name team name or name key
  # @param [Array] family_names list of family names to check
  # @return [String or nil] marked up team name or nil if no markup was needed
  def self.team_name_check_markup(team_name, family_names)
    tn = team_name.downcase.gsub(/[^a-z0-9]/, '').split('')
    fns = family_names.map{|f| f.downcase.gsub(/[^a-z]/, '').split('') }
    # Find a family name that can be formed by only adding to the team name, not deleting.  This
    # means breaking out of the sequence traversal if a '-' is found, i.e. the sequence is okay.
    fn = fns.find { |f| not Diff::LCS::traverse_sequences(f, tn) {|e| break true if e.action == '-' } }
    # Return unmarked team name key unless we found a family name with a problem.
    return fn ? markup(fn, tn).join('').html_safe : nil
  end

  # @param [String] a original string
  # @param [String] b modified version of original string
  # @return [String] original marked up with insertions and deletions to obtain modified
  def self.diff_markup(a, b)
    markup(a.to_s.split(' '), b.to_s.split(' ')).join(' ').html_safe
  end

  # @param [Array] a original list of strings wrt which we must find markup
  # @param [Array] b modified version of original list
  # @return [Array] list of strings with HTML markup denoting insertions and deletions
  def self.markup(as, bs)
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
    out
  end

  # Return the number of leaf nodes of a non-flat list.
  # @param [Array] lst possibly nested list
  # @return [Integer] number of leaves
  def self.deep_length(lst)
    lst.is_a?(Array) ? ( lst.inject(0) { |sum, item| sum += deep_length(item) } ) : 1;
  end

  # Args a and b are arrays of 1 or 2 strings.  Produce an array of 1
  # or 2 marked up strings depicting the diff that produces fewest edits.
  # @param [Array] a array of 1 or 2 original strings
  # @param [Array] b array of 1 or 2 modified strings
  # @return [Array] array of 1 or 2 strings marked up with inserts and deletions to make modified out of original
  def self.getMarkedUpPair(a, b)
    if a.length == b.length
      a.zip(b).map {|p| diff_markup(*p)}
    elsif a.length == 2 && b.length == 1
      deep_length(Diff::LCS::diff(a[0], b[0])) <= deep_length(Diff::LCS::diff(a[1], b[0])) ?
        [ diff_markup(a[0], b[0]), "#{DEL_TAG}#{a[1]}#{END_TAG}".html_safe ] :
        [ "#{DEL_TAG}#{a[0]}#{END_TAG}".html_safe, diff_markup(a[1], b[0]) ]
    elsif a.length == 1 && b.length == 2
      deep_length(Diff::LCS::diff(a[0], b[0])) <= deep_length(Diff::LCS::diff(a[0], b[1])) ?
        [ diff_markup(a[0], b[0]), "#{DEL_TAG}#{b[1]}#{END_TAG}".html_safe ] :
        [ "#{DEL_TAG}#{b[0]}#{END_TAG}".html_safe, diff_markup(a[0], b[1]) ]
    end
  end
end