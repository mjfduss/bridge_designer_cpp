class Administrator < ActiveRecord::Base

  attr_accessible :name, :password, :password_confirmation, :password_digest

  future_has_secure_password

  validates :name, :uniqueness => true

  def self.authenticate (name, password)
    admin = Administrator.find_by_name(name)
    logger.info admin ? "Found admin #{admin.inspect}" : "Didn't find admin"
    return admin ? admin.try(:authenticate, password) : nil
  end

end