class Member < ActiveRecord::Base
  include TablesHelper
  include ValidationHelper

  attr_accessible :first_name, :middle_initial, :last_name
  attr_accessible :category, :phone
  attr_accessible :street, :city, :state, :zip, :country
  attr_accessible :school, :school_city
  attr_accessible :school_state, :res_state
  attr_accessible :res_age, :nonres_age
  attr_accessible :res_grade, :nonres_grade
  attr_accessible :sex, :hispanic, :race
  attr_accessor :completed
  
  belongs_to :team
  has_one :parent

  validates :first_name, :presence => true, :length => { :maximum => 40 }
  validates :middle_initial, :length => { :maximum => 1, :message => 'can be only a single character' }
  validates :last_name, :presence => true, :length => { :maximum => 40 }
  validates :category, 
            :presence => { :message => 'must be selected with one of the buttons below' }, 
            :length => { :maximum => 1 }
  validates_inclusion_of :school_state, :in => TablesHelper::STATES, :message => "is invalid"
  validates_inclusion_of :res_state,    :in => TablesHelper::STATES, :message => "is invalid"
  validates_inclusion_of :res_age,      :in => TablesHelper::AGES, :message => "is invalid"
  validates_inclusion_of :nonres_age,   :in => TablesHelper::AGES, :message => "is invalid"
  validates_inclusion_of :res_grade,    :in => TablesHelper::GRADES, :message => "is invalid"
  validates_inclusion_of :nonres_grade, :in => TablesHelper::GRADES, :message => "is invalid"

  validates_each :school_state, :res_state do |record, attr, value|
    record.errors.add(attr, 'must be selected') if value == '-' && attr == ValidationHelper.to_state_selector(record.category)
  end

  validates_each :res_age, :nonres_age do |record, attr, value|
    record.errors.add(attr, 'must be selected') if value == '-' && attr == ValidationHelper.to_age_selector(record.category)
  end

  validates_each :res_grade, :nonres_grade do |record, attr, value|
    record.errors.add(attr, 'must be selected') if value == '-' && attr == ValidationHelper.to_grade_selector(record.category)
  end

  # TODO USA-specific validations.

  with_options :if => :completed do |v|
    v.validates :street, :presence => true, :length => { :maximum => 40 }
    v.validates :phone, :presence => true, :length => { :maximum => 16 }
    v.validates :city, :presence => true, :length => { :maximum => 40 }
    v.validates :state,  :presence => true, :length => { :maximum => 40 }
    v.validates :zip,  :presence => true, :length => { :minimum => 5, :maximum => 16 }
    v.validates :country, :presence => true, :length => { :maximum => 40 }
    v.validates :school,  :presence => true, :length => { :maximum => 40 }
    v.validates :school_city,  :presence => true, :length => { :maximum => 40 }
    v.validates_inclusion_of :sex, :in => TablesHelper::SEXES, :message => "is invalid"
    v.validates_inclusion_of :hispanic, :in => TablesHelper::HISPANICS, :message => "is invalid"
    v.validates_inclusion_of :race, :in => TablesHelper::RACES, :message => "is invalid"
  end

  # Force category to be updated first so pseudo-attributes can see it.
  def update_attributes(attributes)
    self.category = attributes[:category] if attributes && attributes[:category]
    super
  end

  def full_name
    middle_initial.blank? ? "#{first_name} #{last_name}" : "#{first_name} #{middle_initial}. #{last_name}"
  end

  def school_state
    category == 'u' ? reg_state : '-'
  end

  def school_state=(val)
    self.reg_state = val if category == 'u'
  end

  def res_state
    category == 'n' ? reg_state : '-'
  end

  def res_state=(val)
    self.reg_state = val if category == 'n'
  end

  def res_age
    category == 'u' && age > 0 ? age : '-'
  end

  def res_age=(val)
    self.age = val if category == 'u'
  end

  def nonres_age
    category == 'n' && age > 0 ? age : '-'
  end

  def nonres_age=(val)
    self.age = val if category == 'n'
  end

  def res_grade
    category == 'u' && grade > 0 ? grade : '-'
  end

  def res_grade=(val)
    self.grade = val if category == 'u'
  end

  def nonres_grade
    category == 'n' && grade > 0 ? grade : '-'
  end

  def nonres_grade=(val)
    self.grade = val if category == 'n'
  end

  def coppa?
    0 < age && age < 13
  end

  def high_school?
    grade >= 9
  end

  def middle_school?
    0 < grade && grade <= 8
  end

  def parent_formatted
    parent ? "#{parent.full_name}, #{parent.email}" : '--'
  end

  def school_level_formatted
    if middle_school?
      'Middle School'
    elsif high_school?
      'High School'
    else
      'No School'
    end
  end

  def category_formatted
    case category
      when 'u'
        "US #{school_level_formatted}, #{reg_state}"
      when 'n'
        "Non-US #{school_level_formatted}, #{reg_state} citizen"
      when 'o'
        'Open competitor'
      else
        '[unknown]'
    end
  end

  def age_grade_formatted
    age == 0 ? '--' : "#{age} Yrs / Grade #{grade}"
  end

  def contact_formatted
    street ? [street, "#{city}, #{state} #{zip} #{country}", "Ph: #{phone}"] : '--'
  end

  def school_formatted
    school && school_city ? "#{school}, #{school_city}" : '--  '
  end

  def demographics_formatted
    return '--' unless sex
    rtn = []
    rtn.push(TablesHelper::SEX_MAP[sex]) unless sex == '-'
    rtn.push("Hispanic: #{TablesHelper::HISPANIC_MAP[hispanic]}") unless hispanic == '-'
    rtn.push("Race: #{TablesHelper::RACE_MAP[race]}") unless race == '-'
    rtn = Team::NONE if rtn.blank?
    rtn
  end
end
