module ValidationHelper

  # Convert a category letter to tag of corresponding state selector
  def self.to_state(category)
    case category
      when 'u', :u 
        :school_state
      when 'n', :n
        :res_state
      else 
        nil
    end
  end

end
