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
    s = category == 'u' ? reg_state : '--';
    logger.debug "school_state is #{s}"
    return s
  end

  def school_state=(val)
    logger.debug "setting school_state w/ val #{val}, cat #{category}"
    self.reg_state = val if category == 'u'
    logger.debug "reg_state is now #{reg_state}"
  end

  def res_state
    s = category == 'n' ? reg_state : '--';
    logger.debug "res_state is #{s}"
    return s
  end

  def res_state=(val)
    logger.debug "setting reg_state w/ val #{val}, cat #{category}"
    self.reg_state = val if category == 'n'
    logger.debug "reg_state is now #{reg_state}"
  end

end
