#encoding: utf-8

#------------------------------------------------------------------------------
#
# Lookup Tables
#
# These are the lookup tables for core TransAM
#
#------------------------------------------------------------------------------

condition_types = [
  {:active => 1, :name => 'Unknown',        :rating => 0.0, :description => 'Asset condition is unknown.'},
  {:active => 1, :name => 'Poor',           :rating => 1.0, :description => 'Asset is past its useful life and is in immediate need of repair or replacement. May have critically damaged components.'},
  {:active => 1, :name => 'Marginal',       :rating => 2.0, :description => 'Asset is reaching or is just past the end of its useful life. Increasing number of defective or deteriorated components and experiencing increased maintenance needs.'},
  {:active => 1, :name => 'Adequate',       :rating => 3.0, :description => 'Asset has reached its mid-life. Some moderately defective or deteriorated components.'},
  {:active => 1, :name => 'Good',           :rating => 4.0, :description => 'Asset showing minimal signs of wear. Some defective or deteriorated components.'},
  {:active => 1, :name => 'New/Excellent',  :rating => 5.0, :description => 'New asset. No visible defects.'}
]

disposition_types = [
  {:active => 1, :name => 'Unknown',      :code => 'U', :description => 'Asset disposition is unknown.'},
  {:active => 1, :name => 'Public Sale',  :code => 'P', :description => 'Sold at public auction or other method.'},
  {:active => 1, :name => 'Transferred',  :code => 'T', :description => 'Transferred to another transportation provider.'},
  {:active => 1, :name => 'Reprovisioned',:code => 'R', :description => 'Reprovisioned as a spare or backup.'},
  {:active => 1, :name => 'Trade-In',     :code => 'I', :description => 'Trade in on purchase of new asset.'}
]
service_status_types = [
  {:active => 1, :name => 'Unknown',              :code => 'U', :description => 'Asset service status is unknown.'},
  {:active => 1, :name => 'Start Service',        :code => 'S', :description => 'Asset first placed into service.'},
  {:active => 1, :name => 'Suspend Service',      :code => 'H', :description => 'Asset is temporarily out of service.'},
  {:active => 1, :name => 'In Service',           :code => 'O', :description => 'Asset is in service and operational.'},
  {:active => 1, :name => 'Discontinue Service',  :code => 'X', :description => 'Asset is permanently out of service.'}
]

cost_calculation_types = [
  {:active => 1, :name => 'Replacement Cost',             :class_name => "ReplacementCostCalculator",             :description => 'Calculate the replacement cost using the policy schedule only.'},
  {:active => 1, :name => 'Replacement Cost + Interest',  :class_name => "ReplacementCostPlusInterestCalculator", :description => 'Calculate the replacement cost using the policy schedule plus interest accrued between policy year and replacement year.'},
  {:active => 1, :name => 'Purchase Price + Interest',    :class_name => "PurchasePricePlusInterestCalculator",   :description => 'Calculate the replacement cost using the initial purchase price with accrued interest until the replacement year.'}
]

depreciation_calculation_types = [
  {:active => 1, :name => 'Straight Line',      :class_name => "StraightLineDepreciationCalculator",      :description => 'Calculates the value of an asset using a straight line depreciation method.'},
  {:active => 1, :name => 'Declining Balance',  :class_name => "DecliningBalanceDepreciationCalculator",  :description => 'Calculates the value of an asset using a double declining balance depreciation method.'}
]

license_types = [
  {:active => 1, :name => 'Full',              :asset_manager => 1, :web_services => 1, :description => 'Access to application and web services.'},
  {:active => 1, :name => 'Application Only',  :asset_manager => 1, :web_services => 0, :description => 'Access to application only.'},
  {:active => 1, :name => 'Web Services Only', :asset_manager => 0, :web_services => 1, :description => 'Access to web services only.'}
]

priority_types = [
  {:active => 1, :is_default => 0, :name => 'Low',     :description => 'Lowest priority.'},
  {:active => 1, :is_default => 1, :name => 'Normal',  :description => 'Normal priority.'},
  {:active => 1, :is_default => 0, :name => 'High',    :description => 'Highest priority.'}
]

file_status_types = [
  {:active => 1, :name => 'Unprocessed',  :description => 'Unprocessed.'},
  {:active => 1, :name => 'In Progress',  :description => 'In Progress.'},
  {:active => 1, :name => 'Complete',     :description => 'Complete.'},
  {:active => 1, :name => 'Errored',      :description => 'Errored.'}
]

task_status_types = [
  {:active => 1, :name => 'Not Started',  :description => 'Not Started.'},
  {:active => 1, :name => 'In Progress',  :description => 'In Progress.'},
  {:active => 1, :name => 'Complete',     :description => 'Complete.'},
  {:active => 1, :name => 'Halted Pending Input',      :description => 'Halted Pending Input.'},
  {:active => 1, :name => 'Cancelled',    :description => 'Cancelled.'}
]

attachment_types = [
  {:active => 1, :name => 'Photo',    :display_icon_name => "fa fa-picture-o",    :description => 'Photo.'},
  {:active => 1, :name => 'Document', :display_icon_name => "fa fa-file-text-o",  :description => 'Scanned document.'}
]

district_types = [
  {:active => 1, :name => 'State',        :description => 'State.'},
  {:active => 1, :name => 'District',     :description => 'Engineering District.'},
  {:active => 1, :name => 'MSA',          :description => 'Metropolitan Statistical Area.'},
  {:active => 1, :name => 'County',       :description => 'County.'},
  {:active => 1, :name => 'City',         :description => 'City.'},
  {:active => 1, :name => 'Borough',      :description => 'Borough.'},
  {:active => 1, :name => 'MPO/RPO',      :description => 'MPO or RPO planning area.'},
  {:active => 1, :name => 'Postal Code',  :description => 'ZIP Code or Postal Area.'}
]

report_types = [
  {:active => 1, :name => 'Inventory Report',     :display_icon_name => "fa fa-bar-chart-o",  :description => 'Inventory Report.'},
  {:active => 1, :name => 'Capital Needs Report', :display_icon_name => "fa fa-usd",          :description => 'Capital Needs Report.'},
  {:active => 1, :name => 'Tabular Report',       :display_icon_name => "fa fa-table",        :description => 'Custom SQL Report.'}
]

location_reference_types = [
  {:active => 1, :name => 'Well Known Text',        :format => "WELL_KNOWN_TEXT", :description => 'Location is determined by a well known text (WKT) string.'},
  {:active => 1, :name => 'Route/Milepost/Offset',  :format => "LRS",             :description => 'Location is determined by a route milepost and offset.'},
  {:active => 1, :name => 'Street Address',         :format => "ADDRESS",         :description => 'Location is determined by a geocoded street address.'},
  {:active => 1, :name => 'Map Location',           :format => "COORDINATE",      :description => 'Location is determined by deriving a location from a map.'},
  {:active => 1, :name => 'GeoServer',              :format => "GEOSERVER",       :description => 'Location is determined by deriving a location from Geo Server.'}
]

lookup_tables = %w{condition_types disposition_types cost_calculation_types license_types priority_types
  file_status_types attachment_types district_types report_types location_reference_types service_status_types
  depreciation_calculation_types task_status_types
  }

puts ">>> Loading Core Lookup Tables <<<<"
lookup_tables.each do |table_name|
  puts "  Processing #{table_name}"
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name}")
  data = eval(table_name)
  klass = table_name.classify.constantize
  data.each do |row|
    x = klass.new(row)
    x.save!
  end
end
