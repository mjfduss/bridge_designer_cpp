require 'asset.rb'

class Image < Asset
  attr_accessible :name, :content, :height, :width
end

