#------------------------------------------------------------------------------
#
# PolicyAnalyzer
#
# Wraps a policy for an asset and provides a shortcut for accessing the policy
# rules for the asset. The class uses a combination of factory and decorator
# patterns to create a read-only analyzer instance for an asset then provide
# accessors that delegate to the correct underlying model using reflection.
#
# The service exposes a set of get_xxxxx methods which delegate to the underlying
# models without the caller needing to know which object contains the actual
# property being accessed. Any methods which match the method signature and that
# are not found will return nil and a warning message will be generated.
#
# Any warnings are stacked into the @warnings property and can be tested
# by calling warnings?
#
# Direct access to the model details can be obtained through the attr_reader
# properties
#------------------------------------------------------------------------------
class PolicyAnalyzer

  DECORATOR_METHOD_SIGNATURE = /^get_(.*)$/

  attr_reader :asset
  attr_reader :policy
  attr_reader :asset_type_rule
  attr_reader :asset_subtype_rule
  attr_reader :replace_asset_subtype_rule
  attr_reader :warnings

  #-----------------------------------------------------------------------------
  # Recieves method requests. Anything that does not start with get_ is delegated
  # to the super model otherwise the request is tested against the model components
  # until a match is found or not in which case the call is delegated to the super
  # model to be evaluated
  #-----------------------------------------------------------------------------
  def method_missing(method_sym, *arguments)

    if method_sym.to_s =~ DECORATOR_METHOD_SIGNATURE
      # Strip off the decorator and see who can handle the real request
      actual_method_sym = method_sym.to_s[4..-1].to_sym
      if policy.respond_to? actual_method_sym
        method_object = policy.method(actual_method_sym)
        method_object.call(*arguments)
      elsif asset_type_rule.respond_to? actual_method_sym
        method_object = asset_type_rule.method(actual_method_sym)
        returned_val = method_object.call(*arguments)

        # ================================= #
        # check if theres a replace rule
        # if there is, check that the replacement cost calculation type does not use the purchase price calculator
        if replace_asset_subtype_rule.present?
          purchase_price_calculator = CostCalculationType.find_by(class_name: 'PurchasePricePlusInterestCalculator')

          # then if uses the purchase price calculator default to replacement (plus interest) calculator
          if returned_val ==  purchase_price_calculator
            CostCalculationType.find_by(class_name: 'ReplacementCostPlusInterestCalculator')
          elsif replace_asset_subtype_rule.present? && actual_method_sym == :replacement_cost_calculation_type_id && returned_val ==  purchase_price_calculator.id
            CostCalculationType.find_by(class_name: 'ReplacementCostPlusInterestCalculator').id
          else
            # for all other calculators just return the value
            returned_val
          end
        else
          # for all other asset type rule fields just return the value
          returned_val
        end
        # ================================= #

      elsif !actual_method_sym.to_s.starts_with?('replace_') && !actual_method_sym.to_s.starts_with?('min_') && replace_asset_subtype_rule.respond_to?(actual_method_sym)
        method_object = replace_asset_subtype_rule.method(actual_method_sym)
        method_object.call(*arguments)
      elsif asset_subtype_rule.respond_to? actual_method_sym
        method_object = asset_subtype_rule.method(actual_method_sym)
        method_object.call(*arguments)
      else
        @warnings << "Method #{method_sym.to_s} not valid."
        nil
      end
    else
      puts "Method #{method_sym.to_s} wiht #{arguments}"
      # Pass the call on -- probably generates a method not found exception
      super
    end
  end

  #-----------------------------------------------------------------------------
  # See if we respond to the method request
  #-----------------------------------------------------------------------------
  def respond_to?(method_sym, include_private = false)

    if method_sym.to_s =~ DECORATOR_METHOD_SIGNATURE
      actual_method_sym = method_sym.to_s[4..-1].to_sym
      if policy.respond_to? actual_method_sym or asset_type_rule.respond_to? actual_method_sym or asset_subtype_rule.respond_to? actual_method_sym
        true
      else
        @warnings << "Method #{method_sym.to_s} not valid."
      end
    else
      # Pass it up the chain
      super
    end
  end

  #------------------------------------------------------------------------------
  # Factor style constructor
  #------------------------------------------------------------------------------
  def initialize(asset, policy)
    @asset = asset
    @policy = policy
    @warnings = []
    if @policy.present? and @asset.present?
      @asset_type_rule = @policy.policy_asset_type_rules.find_by(:asset_type_id => asset.asset_type_id)
      @asset_subtype_rule = @policy.policy_asset_subtype_rules.find_by(:asset_subtype_id => @asset.asset_subtype_id, :fuel_type_id => @asset.fuel_type_id)
      if @asset_subtype_rule.try(:replace_asset_subtype_id).present? || @asset_subtype_rule.try(:replace_fuel_type_id).present?
        @replace_asset_subtype_rule = @policy.policy_asset_subtype_rules.find_by(:asset_subtype_id => (@asset_subtype_rule.replace_asset_subtype_id || @asset.asset_subtype_id), :fuel_type_id => (@asset_subtype_rule.replace_fuel_type_id || @asset.fuel_type_id))
      end
    else
      @warnings << "Policy not found for asset #{asset} with class #{asset.asset_type}"
    end
    @warnings << "Asset Type Rule not found for asset #{asset} with class #{asset.asset_type}" if @asset_type_rule.blank?
    @warnings << "Asset Subtype Rule not found for asset #{asset} with class #{asset.asset_subtype}" if @asset_subtype_rule.blank?
  end

  def valid?
    @warnings.empty?
  end

  def warnings?
    @warnings.present?
  end

  #------------------------------------------------------------------------------
  # Protected Methods
  #------------------------------------------------------------------------------
  protected

  #------------------------------------------------------------------------------
  # Private Methods
  #------------------------------------------------------------------------------
  private

end