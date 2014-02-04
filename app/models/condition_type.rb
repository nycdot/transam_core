class ConditionType < ActiveRecord::Base

  # Enable auditing of this model type
  has_paper_trail
  
  #attr_accessible :name, :description, :active, :rating
        
  # default scope
  default_scope { where(:active => true) }
 
  def self.max_rating 
    order("rating DESC").first.rating
  end
  def self.min_rating 
    where('name <> ?', 'Unknown').order("rating ASC").first.rating
  end
  
  def self.from_rating(estimated_rating)
    return if estimated_rating.nil?
    # Round the condition type to the nearest whole number
    val = (estimated_rating + 0.5).floor
    # bound it
    val = [val, max_rating].min
    val = [val, min_rating].max
    ConditionType.where("rating = ?", val).first
  end

end