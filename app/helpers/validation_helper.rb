module ValidationHelper

  # Convert a category letter to tag of corresponding state selector
  def self.to_state_selector(category)
    case category
      when 'u', :u 
        :school_state
      when 'n', :n
        :res_state
      else 
        nil
    end
  end

  # Convert a category letter to tag of corresponding age selector
  def self.to_age_selector(category)
    case category
      when 'u', :u
        :res_age
      when 'n', :n
        :nonres_age
      else
        nil
    end
  end

  # Convert a category letter to tag of corresponding grade selector
  def self.to_grade_selector(category)
    case category
      when 'u', :u
        :res_grade
      when 'n', :n
        :nonres_grade
      else
        nil
    end
  end

end
