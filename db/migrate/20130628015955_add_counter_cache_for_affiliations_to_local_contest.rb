class AddCounterCacheForAffiliationsToLocalContest < ActiveRecord::Migration
  def change
    add_column :local_contests, :affiliations_count, :integer, :default => 0, :null => false
    LocalContest.reset_column_information
    LocalContest.all.each do |lc|
      LocalContest.update_counters lc.id, :affiliations_count => lc.affiliations.length
    end
  end
end
