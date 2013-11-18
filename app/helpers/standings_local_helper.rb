module StandingsLocalHelper

  PREVIOUS_LINK = '&#8592; Previous'.html_safe
  NEXT_LINK = 'Next &#8594;'.html_safe

  # Return page index HTML for a local scoreboard.
  # <div class="pagination">
  # <span class="previous_page disabled">← Previous</span>
  # <em>1</em>
  # <a href="/users?page=2">2</a>
  # <a href="/users?page=3">3</a>
  # <a href="/users?page=4">4</a>
  # <a class="next_page" href="/users?page=2">Next →</a>
  # </div>
  def page_index(lsb)
    return nil unless lsb[:page_count] > 1
    lsb_page = lsb[:page].to_i
    lsb_page_count = lsb[:page_count].to_i
    content_tag(:div, :class => 'pagination') do
      s = ''.html_safe
      s << if lsb_page <= 1
             content_tag(:span, :class => 'previous_page disabled') { PREVIOUS_LINK }
           else
             link_to(PREVIOUS_LINK, standings_local_path(:page => lsb_page - 1))
           end
      1.upto(lsb_page_count) do |page|
        s << if page == lsb_page
               content_tag(:em) { page.to_s }
             else
               link_to(page, standings_local_path(:page => page))
             end
      end
      s << if lsb_page >= lsb_page_count
             content_tag(:span, :class => 'next_page disabled') { NEXT_LINK }
           else
             link_to(NEXT_LINK, standings_local_path(:page => lsb_page + 1))
           end
    end
  end
end