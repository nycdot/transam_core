class CurrentNeedsReport < NeedsReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(organization_id_list, params)
        
    # Check to see if we got an asset type to sub select on
    if params[:report_filter_type] 
      report_filter_type = params[:report_filter_type].to_i
    else
      report_filter_type = 0
    end
        
    analysis_year = Date.today.year
    
    assets = get_assets(organization_id_list, analysis_year, report_filter_type)
    
    return calc_need(assets)

  end
  
end
