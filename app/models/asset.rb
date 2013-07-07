class Asset < ActiveRecord::Base
  belongs_to :assetable, :polymorphic => true
  has_many :assets, :as => :assetable
end
