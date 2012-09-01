class Member < ActiveRecord::Base
  include TablesHelper
  include ValidationHelper

  attr_accessible :first_name, :middle_initial, :last_name
  attr_accessible :category, :age, :grade, :phone
  attr_accessible :street, :city, :state, :zip
  attr_accessible :school, :school_city
  attr_accessible :school_state, :res_state
  attr_accessible :sex, :hispanic, :race
  
  belongs_to :team

  validates :first_name, :presence => true, :length => { :maximum => 40 }
  validates :middle_initial, :length => { :maximum => 1 }
  validates :last_name, :presence => true, :length => { :maximum => 40 }
  validates :category, 
            :presence => { :message => 'must be selected with one of the buttons below' }, 
            :length => { :maximum => 1 }
  validates_inclusion_of :school_state, :in => TablesHelper::STATES, :message => "is invalid."
  validates_inclusion_of :res_state,    :in => TablesHelper::STATES, :message => "is invalid."
 
  validates_each :school_state, :res_state do |record, attr, value|
    record.errors.add(attr, 'must be selected.') \
      if value == '--' && attr == ValidationHelper.to_state(record.category)
  end

  def full_name
    return first_name.nil? || last_name.nil? ? '' :
      (middle_initial && middle_initial.length > 0) ? 
      "#{first_name} #{middle_initial}. #{last_name}" : 
      "#{first_name} #{last_name}"
  end

  def school_state
    return category == 'u' ? reg_state : '--';
  end

  def school_state=(val)
    self.reg_state = val if category == 'u'
  end

  def res_state
    return category == 'n' ? reg_state : '--';
  end

  def res_state=(val)
    self.reg_state = val if category == 'n'
  end

end
