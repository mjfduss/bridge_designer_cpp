class Member < ActiveRecord::Base
  include TablesHelper
  include ValidationHelper

  attr_accessible :first_name, :middle_initial, :last_name
  attr_accessible :category, :age, :grade, :phone
  attr_accessible :street, :city, :state, :zip, :country
  attr_accessible :school, :school_city
  attr_accessible :school_state, :res_state
  attr_accessible :sex, :hispanic, :race
  attr_accessor :completed
  
  belongs_to :team

  validates :first_name, :presence => true, :length => { :maximum => 40 }
  validates :middle_initial, :length => { :maximum => 1 }
  validates :last_name, :presence => true, :length => { :maximum => 40 }
  validates :category, 
            :presence => { :message => 'must be selected with one of the buttons below' }, 
            :length => { :maximum => 1 }
  validates_inclusion_of :school_state, :in => TablesHelper::STATES, :message => "is invalid"
  validates_inclusion_of :res_state,    :in => TablesHelper::STATES, :message => "is invalid"

  validates_each :school_state, :res_state do |record, attr, value|
    record.errors.add(attr, 'must be selected') if value == '-' && attr == ValidationHelper.to_state_selector(record.category)
  end

  # TODO USA-specific validations.

  with_options :if => :completed do |v|
    v.validates_inclusion_of :age, :in => TablesHelper::VALID_AGES, :message => "must be selected"
    v.validates_inclusion_of :grade, :in => TablesHelper::VALID_GRADES, :message => "must be selected"
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

  def full_name
    middle_initial.blank? ? "#{first_name} #{last_name}" : "#{first_name} #{middle_initial}. #{last_name}"
  end

  def school_state
    return category == 'u' ? reg_state : '-';
  end

  def school_state=(val)
    self.reg_state = val if category == 'u'
  end

  def res_state
    return category == 'n' ? reg_state : '-';
  end

  def res_state=(val)
    self.reg_state = val if category == 'n'
  end

  def category_formatted
    case category
      when 'u'
        "Attending U.S. K-12 #{reg_state}"
      when 'n'
        "K-12 citizen OCONUS #{reg_state}"
      when 'o'
        'Open competitor'
      else
        '[unknown]'
    end
  end

  def age_grade_formatted
    "#{age} Yrs / Grade #{grade}"
  end

  def contact_formatted
    [street, "#{city}, #{state} #{zip} #{country}", "Ph: #{phone}"]
  end

  def school_formatted
    "#{school}, #{school_city}"
  end

  def demographics_formatted
    rtn = []
    rtn.push(TablesHelper::SEX_MAP[sex]) unless sex == '-'
    rtn.push(["Hispanic:",  TablesHelper::HISPANIC_MAP[hispanic]]) unless hispanic == '-'
    rtn.push(["Race:", TablesHelper::RACE_MAP[race]]) unless race == '-'
    rtn = Team::NONE if rtn.blank?
    rtn
  end
end
