class ActiveSupport::HashWithIndifferentAccess
  def nonblank?(key)
    key?(key) && !fetch(key).blank?
  end
end