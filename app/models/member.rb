class Member < ActiveRecord::Base
  attr_accessible :first_name, :middle_initial, :last_name
  attr_accessible :category, :age, :grade, :phone
  attr_accessible :street, :city, :state, :zip
  attr_accessible :school, :school_city
  attr_accessible :school_state, :res_state
  attr_accessible :sex, :hispanic, :race
  
  belongs_to :team

  validates :first_name, :presence => true, :length => { :maximum => 40 }
  validates :last_name, :presence => true, :length => { :maximum => 40 }
  validates :category, :presence => true, :length => { :maximum => 1 }

  def school_state
    return category == 'u' ? reg_state : '';
  end

  def school_state=(val)
    reg_state = val if category == 'u'
  end

  def res_state
    return category == 'n' ? reg_state : '';
  end

  def res_state=(val)
    reg_state = val if category == 'n'
  end

end
