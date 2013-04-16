class LocalContest < ActiveRecord::Base

  include ActionView::Helpers::UrlHelper

  default_scope order("code ASC")

  attr_accessible :code, :description
  attr_accessible :poc_first_name, :poc_middle_initial, :poc_last_name, :poc_position
  attr_accessible :organization, :city, :state, :zip, :phone, :link

  has_many :affiliations
  has_many :teams, :through => :affiliations

  before_validation :upcase_code
  before_validation :clean_link

  validates :code, :uniqueness => true,
                   :format => { :with => /\A[0-9A-Z]{3}(?:[0-9A-Z]|\d\d[A-D]\Z)/,
                                :message => 'must be a correct 4- or 6-character local contest identifier.'}
  validates :description, :presence => true, :length => { :maximum => 40 }
  validates :poc_first_name, :length => { :maximum => 40 }
  validates :poc_middle_initial, :length => { :maximum => 1 }
  validates :poc_last_name, :length => { :maximum => 40 }
  validates :poc_position, :length => { :maximum => 40 }
  validates :organization, :length => { :maximum => 40 }
  validates :city,  :length => { :maximum => 40 }
  validates :state, :length => { :maximum => 40 }
  validates :zip, :length => { :maximum => 9 }, :numericality => { :only_integer => true }, :allow_blank => true
  validates :phone, :length => { :maximum => 16 }
  validates :link, :length => { :maximum => 40 }

  def formatted(visible = %w(description poc poc_position phone link created))
    visible.map { |item| send("#{item}_formatted") }
  end

  def description_formatted
    [ "Description", description ]
  end

  def phone_formatted
    [ "Phone", phone ]
  end

  def poc_formatted
    [ "POC", poc_full_name ]
  end

  def link_formatted
    link.include?('@') ? ["Email", mail_to(link) ] : ["Web", link_to(link, link) ]
  end

  def poc_position_formatted
    [ "POC position", poc_full_position ]
  end

  def created_formatted
    [ "Created", created_at ]
  end

  def poc_full_name
    poc_middle_initial.blank? ? "#{poc_first_name} #{poc_last_name}" : "#{poc_first_name} #{poc_middle_initial}. #{poc_last_name}"
  end

  def poc_full_position
    p = []
    p.push(poc_position) unless poc_position.blank?
    p.push(organization) unless organization.blank?
    p.push(city) unless city.blank?
    p.push(state) unless state.blank?
    p.push(zip) unless zip.blank?
    p.join(', ')
  end

  protected

  def upcase_code
    self.code = code.upcase unless code.blank?
  end

  def clean_link
    self.link = "http://" + link unless link.blank? || link =~ /@|https?:\/\//
  end
end