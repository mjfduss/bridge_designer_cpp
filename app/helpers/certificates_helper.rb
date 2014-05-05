module CertificatesHelper

  def cut_mark(pdf, x, y, dx, dy, size = 0.2.in, margin = 0.15)
    dx *= size
    dy *= size
    pdf.stroke_line [x - margin * dx, y], [x - dx, y]
    pdf.stroke_line [x, y - margin * dy], [x, y - dy]
  end

end
