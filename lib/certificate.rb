require 'prawn'
require 'prawn/measurement_extensions'

module Certificate

  Prawn::Document.generate('certificate.pdf',
                           :page_size => 'LETTER',
                           :page_layout => :landscape) do |pdf|
    pdf.bounding_box [pdf.bounds.left + 0.25.in, pdf.bounds.top], :width => 9.5.in, :height => 7.5.in do
      pdf.image "#{File.dirname(__FILE__)}/bg.png", :position => 0.26.in, :vposition => 3.in, :scale => 0.5
      pdf.font 'Times-Roman'
      pdf.stroke_color = '008800'
      pdf.stroke_bounds
      d = 8
      # puts "bounds: lft=#{pdf.bounds.left} w=#{pdf.bounds.width} top=#{pdf.bounds.top} h=#{pdf.bounds.height}"
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

          #pdf.move_down 0.25.in
          pdf.font "#{File.dirname(__FILE__)}/ProgressiveText.ttf" do
            pdf.font_size 0.75.in
            pdf.text 'Certificate Of Achievement', :align => :center
          end

          pdf.move_down 0.2.in
          pdf.text 'is awarded to', :align => :center

          pdf.move_down 0.2.in
          pdf.font_size 0.35.in do
            pdf.text 'Team Software Bridges', :align => :center
          end

          pdf.move_down 0.14.in
          pdf.font pdf.font.name, :style => :bold do
            if false
              pdf.text 'Eugene K. Ressler', :align => :center
              pdf.text 'Stephen J. Ressler', :align => :center
            else
              pdf.move_down 0.06.in
              pdf.text 'Eugene K. Ressler', :align => :center
              pdf.move_down 0.03.in
            end
          end

          pdf.move_down 0.20.in
          pdf.text 'For attaining a rank of 17 out of 1432 teams', :align => :center

          pdf.move_down 0.1.in
          pdf.text 'in the National', :align => :center

          pdf.move_down 0.1.in
          pdf.text 'Engineering Encounters Bridge Design Contest', :align => :center

          pdf.move_down 0.1.in
          pdf.text 'on January 27th, 2014', :align => :center

          pdf.bounding_box [pdf.bounds.left + 0.7.in, pdf.bounds.bottom + 1.3.in],
                           :width => 3.in do
            pdf.image 'logo.png', :scale => 0.4
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
            pdf.image 'sig.png', :scale => 0.7
            pdf.move_up 0.2.in
            pdf.font_size 0.2.in do
              pdf.text 'Eugene K. Ressler'
              pdf.text 'Contest Chief Judge'
            end
          end
        end
      end
    end
  end
end