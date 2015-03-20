require 'prawn/measurement_extensions'

prawn_document(:page_layout => :landscape, :force_download => false) do |pdf|

  dir = File.dirname(__FILE__)

  pdf.font_families.update('Playfair-Display' => {
      :normal => File.join(dir, 'PlayfairDisplay-Regular.ttf'),
      :italic => File.join(dir, 'PlayfairDisplay-Italic.ttf'),
      :bold =>   File.join(dir, 'PlayfairDisplay-Bold.ttf'),
  })

  pdf.bounding_box [pdf.bounds.left, pdf.bounds.top + 0.25.in], :width => 10.in, :height => 8.in do
    lw = pdf.line_width
    pdf.line_width = 0.25
    cut_mark(pdf, pdf.bounds.left,  pdf.bounds.bottom, +1, +1)
    cut_mark(pdf, pdf.bounds.left,  pdf.bounds.top,    +1, -1)
    cut_mark(pdf, pdf.bounds.right, pdf.bounds.bottom, -1, +1)
    cut_mark(pdf, pdf.bounds.right, pdf.bounds.top,    -1, -1)
    pdf.font_size 0.1.in
    pdf.draw_text 'Cut marks for 8x10 inch frame', :at => [0.1.in, -0.1.in]
    pdf.line_width = lw
  end

  pdf.bounding_box [pdf.bounds.left + 0.25.in, pdf.bounds.top], :width => 9.5.in, :height => 7.5.in do
    pdf.image File.join(dir, 'bg.png'), :position => 0.75.in, :vposition => 3.2.in, :scale => 0.35
    roman_font = 'Playfair-Display'
    #roman_font 'Times-Roman'
    pdf.font roman_font
    pdf.stroke_color = '004488'
    pdf.stroke_bounds
    d = 8
    pdf.bounding_box [pdf.bounds.left + d, pdf.bounds.top - d],
                     :width => pdf.bounds.width - 2 * d,
                     :height => pdf.bounds.height - 2 * d do
      pdf.line_width = 8
      pdf.stroke_bounds
      pdf.bounding_box [pdf.bounds.left + d, pdf.bounds.top - d],
                       :width => pdf.bounds.width - 2 * d,
                       :height => pdf.bounds.height - 2 * d do
        pdf.line_width = 1
        pdf.stroke_bounds

        pdf.move_down 0.65.in
        pdf.font_size 0.25.in
        pdf.text 'The Engineering Encounters', :align => :center

        pdf.move_down 0.1.in
        pdf.font File.join(dir, 'ProgressiveText.ttf') do
          pdf.font_size 0.75.in
          pdf.text 'Certificate Of Achievement', :align => :center
        end

        sep = 0.13.in

        pdf.move_down sep
        pdf.image File.join(dir, 'ribbon.png'), :scale => 0.3, :at => [7.4.in, pdf.cursor] if @semifinalist
        pdf.text 'is awarded to', :align => :center

        pdf.move_down sep
        pdf.font_size 0.35.in do
          pdf.text "Team #{@team.name}", :align => :center
        end

        pdf.move_down 0.75 * sep
        pdf.font roman_font, :style => :bold do
          if @team.members.length == 2
            pdf.text @team.captain.full_name, :align => :center
            pdf.text @team.non_captains.first.full_name, :align => :center
          else
            pdf.move_down 0.06.in
            pdf.text @team.captain.full_name, :align => :center
            pdf.move_down 0.03.in
          end
        end

        pdf.move_down sep
        pdf.text "For attaining a standing of #{number_with_delimiter(@standing, :delimiter => ',')} of " +
          "#{number_with_delimiter(@basis, :delimiter => ',')} teams", :align => :center

        @group_info.each do |info|
          pdf.move_down 0.5 * sep
          pdf.text "And #{number_with_delimiter(info.standing, :delimiter => ',')} of " +
            "#{number_with_delimiter(info.basis, :delimiter => ',')} " +
            "teams from #{info.group.description}", :align => :center
        end

        pdf.move_down 0.5 * sep
        if @local_contest
          pdf.text "#{@local_contest.description} Local Competition", :align => :center
        else
          pdf.text "#{TablesHelper::CATEGORY_MAP[@team.category]} Division Qualifying Round", :align => :center
        end

        pdf.move_down 0.5 * sep
        pdf.text 'Engineering Encounters Bridge Design Contest', :align => :center

        pdf.move_down sep
        pdf.font roman_font, :style => :italic do
          pdf.text @awarded_on.strftime('%B %e, %Y'), :align => :center
        end

        pdf.bounding_box [pdf.bounds.left + 0.7.in, pdf.bounds.bottom + 1.2.in],
                         :width => 3.in do
          pdf.image File.join(dir, 'logo.png'), :scale => 0.4
          graphic_width = 0.93.in
          pdf.bounding_box [pdf.bounds.left + graphic_width, pdf.bounds.top],
                           :width => pdf.bounds.width - graphic_width do
            pdf.font pdf.font.name, :style => :bold_italic, :size => 0.16.in do
              pdf.move_down 0.2.in
              pdf.text 'Engineering Encounters'
              pdf.text 'Certified'
            end
          end
        end

        pdf.bounding_box [pdf.bounds.right - 2.5.in, pdf.bounds.bottom + 1.3.in],
                         :width => 3.in do
          pdf.image File.join(dir, 'signature.png'), :width => 2.in, :at => [-0.2.in, 0.0.in]
          pdf.move_down 0.5.in
          pdf.font_size 0.2.in do
            pdf.text 'Stephen J. Ressler'
            pdf.text 'Contest Director'
          end
        end
      end
    end
  end
end
