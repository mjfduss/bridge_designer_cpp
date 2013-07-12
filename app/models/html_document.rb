class HtmlDocument < ActiveRecord::Base
  attr_accessible :subject, :text

  def plain_text
    Nokogiri::HTML(text).text
  end

  def self.qbe(params)
    HtmlDocument.where('subject ILIKE ?', "%#{params[:subject]}%")
  end
end
