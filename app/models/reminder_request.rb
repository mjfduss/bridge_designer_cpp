class ReminderRequest < ActiveRecord::Base
  attr_accessible :email, :tag

  validates :email,
            :presence => true,
            :uniqueness => { :message => " is already scheduled for a reminder!" },
            :format => { :with => Team::VALID_EMAIL_ADDRESS, :message => " doesn't seem to have a valid format." }
  validates :referer, :presence => true
  validates :tag, :presence => true

end
