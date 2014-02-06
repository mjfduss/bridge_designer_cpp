require 'prawn/measurement_extensions'

prawn_document(:page_layout => :landscape, :force_download => false) do |pdf|
  dir = File.dirname(__FILE__)
  pdf.bounding_box [pdf.bounds.left + 0.25.in, pdf.bounds.top], :width => 9.5.in, :height => 7.5.in do
    pdf.image File.join(dir, 'bg.png'), :position => 0.26.in, :vposition => 3.in, :scale => 0.5
    pdf.font 'Times-Roman'
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

        pdf.move_down 0.75.in
        pdf.font_size 0.25.in
        pdf.text 'The Engineering Encounters', :align => :center

        pdf.font File.join(dir, 'ProgressiveText.ttf') do
          pdf.font_size 0.75.in
          pdf.text 'Certificate Of Achievement', :align => :center
        end

        pdf.move_down 0.2.in
        pdf.text 'is awarded to', :align => :center

        pdf.move_down 0.2.in
        pdf.font_size 0.35.in do
          pdf.text "Team #{@team.name}", :align => :center
        end

        pdf.move_down 0.14.in
        pdf.font pdf.font.name, :style => :bold do
          if @team.members.length == 2
            pdf.text @team.captain.full_name, :align => :center
            pdf.text @team.non_captains.first.full_name, :align => :center
          else
            pdf.move_down 0.06.in
            pdf.text @team.captain.full_name, :align => :center
            pdf.move_down 0.03.in
          end
        end

        pdf.move_down 0.20.in
        pdf.text "For attaining a rank of #{@standing} out of #{@basis} teams", :align => :center

        pdf.move_down 0.1.in
        pdf.text 'in the National', :align => :center

        pdf.move_down 0.1.in
        pdf.text 'Engineering Encounters Bridge Design Contest', :align => :center

        pdf.move_down 0.1.in
        pdf.text "on #{Time.now.strftime('%B %e, %Y')}", :align => :center

        pdf.bounding_box [pdf.bounds.left + 0.7.in, pdf.bounds.bottom + 1.3.in],
                         :width => 3.in do
          pdf.image File.join(dir, 'logo.png'), :scale => 0.4
          graphic_width = 0.93.in
          pdf.bounding_box [pdf.bounds.left + graphic_width, pdf.bounds.top],
                           :width => pdf.bounds.width - graphic_width do
            pdf.font pdf.font.name, :style => :bold_italic, :size => 0.16.in do
              pdf.move_down 0.1.in
              pdf.text 'Engineering Encounters'
              pdf.text 'Certified'
              pdf.text 'True and Correct'
            end
          end
        end

        pdf.bounding_box [pdf.bounds.right - 2.5.in, pdf.bounds.bottom + 1.5.in],
                         :width => 3.in do
          pdf.image File.join(dir, 'signature.png'), :width => 2.in, :at => [-0.2.in, 0.1.in]
          pdf.move_down 0.5.in
          pdf.font_size 0.2.in do
            pdf.text 'Stephen J. Ressler'
            pdf.text 'Chief Judge'
          end
        end
      end
    end
  end
end
