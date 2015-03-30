#
# Rehabilitation update event. This is event type is required for
# all implementations
#
class RehabilitationUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations
  has_many :asset_event_asset_subsystems, 
             :foreign_key => "asset_event_id", 
             :inverse_of  => :rehabilitation_update_event, 
             :dependent   => :destroy
  accepts_nested_attributes_for :asset_event_asset_subsystems, 
                                  :allow_destroy => true,
                                  :reject_if   => lambda{ |attrs| attrs[:parts_cost].blank? and attrs[:labor_cost].blank? }
  
  has_many :asset_subsystems, :through => :asset_event_asset_subsystems
        
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :extended_useful_life_months,
    :extended_useful_life_miles,
    :asset_event_asset_subsystems_attributes => [AssetEventAssetSubsystem.allowable_params]
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
  end
    
  #returns the asset event type for this type of event
  def self.asset_event_type
    AssetEventType.find_by_class_name(self.name)
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def get_update
    "Rehabilitation: $#{cost}: #{asset_subsystems.join(",")}"
  end

  def cost
    parts_cost + labor_cost # sum up the costs from subsystems
  end

  # Cost for each piece is the sum of what's spent on subsystems
  def parts_cost
    asset_event_asset_subsystems.map(&:parts_cost).compact.reduce(0, :+)
  end
  def labor_cost
    asset_event_asset_subsystems.map(&:labor_cost).compact.reduce(0, :+)
  end
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
  end    
  
end
