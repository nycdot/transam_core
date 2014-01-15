#------------------------------------------------------------------------------
#
# Transit Agency
#
# Represents a basic organization that has transit assets
#
#------------------------------------------------------------------------------
class TransitAgency < Organization
  
  #------------------------------------------------------------------------------
  # Callbacks 
  #------------------------------------------------------------------------------
  after_initialize :set_defaults
  
  #------------------------------------------------------------------------------
  # Associations 
  #------------------------------------------------------------------------------
  
  # every transit agency can own assets
  has_many :assets, :foreign_key => 'organization_id'
    
  # every transit agency can have 0 or mroe policies
  has_many :policies
  
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  
  # List of allowable form param hash keys  
  FORM_PARAMS = [
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
      
  def self.allowable_params
    FORM_PARAMS
  end
            
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Dependent on inventory
  def has_assets?
    assets.count > 0
  end   
       
  # returns the count of assets of the given type. If no type is selected it returns the total
  # number of assets
  def asset_count(asset_type = nil) 
    asset_type.nil? ? assets.count : assets.where('asset_type_id = ?', asset_type.id).count
  end
    
  # Returns a policy for a transit organization
  def get_policy
    # get a typed version of the organization and return its value
    org = is_typed? ? self : Organization.get_typed_organization(self)
    return org.get_policy unless org.nil?    
  end
    
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new organization
  def set_defaults
    super
  end    
  
end
      
