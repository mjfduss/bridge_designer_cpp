class TrueClass
  def to_s(style = :boolean)
    case style
      when :word then 'yes'
      when :Word then 'Yes'
      when :number then '1'
      else 'true'
    end
  end
end

class FalseClass
  def to_s(style = :boolean)
    case style
      when :word then 'no'
      when :Word then 'No'
      when :number then '0'
      else 'false'
    end
  end
end
