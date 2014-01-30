require 'prawn'
require 'prawn/measurement_extensions'

module Certificate

  Prawn::Document.generate('certificate.pdf',
                           :page_size => 'LETTER',
                           :page_layout => :landscape) do |pdf|
    pdf.stroke_color = '008800'
    pdf.stroke_bounds
    d = 8
    puts "bounds: lft=#{pdf.bounds.left} w=#{pdf.bounds.width} top=#{pdf.bounds.top} h=#{pdf.bounds.height}"
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
        pdf.font "ProgressiveText.ttf" do
          pdf.font_size 0.75.in
          pdf.text 'Certificate Of Achievement', :align => :center
        end

        pdf.move_down 0.4.in
        pdf.text 'is awarded to', :align => :center

        pdf.move_down 0.4.in
        pdf.text 'Team Software Bridges', :align => :center

        pdf.move_down 0.1.in
        pdf.text 'Eugene K. Ressler', :align => :center
        pdf.text 'Stephen J. Ressler', :align => :center

        pdf.move_down 0.1.in
        pdf.text 'For attaining a rank of 17 out of 1432 teams', :align => :center

        pdf.move_down 0.1.in
        pdf.text 'in the', :align => :center
        pdf.text 'Engineering Encounters Bridge Design Contest', :align => :center

        pdf.move_down 0.1.in
        pdf.text 'on January 27th in the year 2014', :align => :center

        pdf.bounding_box [pdf.bounds.right - 3.in, pdf.bounds.bottom + 1.5.in],
                         :width => 3.in, :height => 1.5.in do
          pdf.stroke_bounds
        end
      end
    end
  end
end