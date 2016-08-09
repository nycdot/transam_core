#------------------------------------------------------------------------------
#
# DispositionUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing inventory
#
#------------------------------------------------------------------------------
class DispositionUpdatesTemplateBuilder < TemplateBuilder

  SHEET_NAME = DispositionUpdatesFileHandler::SHEET_NAME

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)
    @asset_types.each do |asset_type|
      assets = @organization.assets.operational.where('asset_type_id = ?', asset_type).order(:asset_type_id, :asset_subtype_id, :asset_tag)
      assets.each do |asset|
        next unless asset.disposable? 
        
        row_data  = []
        row_data << asset.object_key
        row_data << asset.asset_type.name
        row_data << asset.asset_subtype.name
        row_data << asset.asset_tag
        row_data << asset.external_id
        row_data << asset.description

        # Disposition report
        row_data << nil
        row_data << nil
        row_data << nil

        sheet.add_row row_data, :types => row_types
      end
    end
  end

  # Configure any other implementation specific options for the workbook
  # such as lookup table worksheets etc.
  def setup_workbook(workbook)

    # Add a lookup table worksheet and add the lookuptable values we need to it
    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    sheet.sheet_protection.password = 'transam'

    row = []
    @disposition_types = DispositionType.active.pluck(:name)
    @disposition_types.each do |x|
      row << x unless x.eql? "Unknown" or x.eql? "Transferred"
    end
    sheet.add_row row

  end

  # Performing post-processing
  def post_process(sheet)

    # protect sheet so you cannot update cells that are locked
    sheet.sheet_protection

    # Merge Cells
    sheet.merge_cells("A1:F1")
    sheet.merge_cells("G1:I1")

    # Add data validation constraints

    # This is used to get the column name of a lookup table based on its length
    alphabet = ('A'..'Z').to_a
    earliest_date = SystemConfig.instance.epoch

    # Disposition Date
    sheet.add_data_validation("G3:G1000", {
      :type => :time,
      :operator => :greaterThan,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Disposition Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    # Disposition Type
    sheet.add_data_validation("H3:H1000", {
      :type => :list,
      :formula1 => "lists!$A$1:$#{alphabet[@disposition_types.size]}$1",
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Disposition Type',
      :prompt => 'Only values in the list are allowed'})

    # Sales proceeds
    sheet.add_data_validation("I3:I1000", {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => '0',
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Value must be greater than 0.',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Sales proceeds',
      :prompt => 'Enter a value greater than or equal to 0'})

  end

  # header rows
  def header_rows
    [
      [
        'Asset',
        '',
        '',
        '',
        '',
        '',
        'Disposition Report',
        '',
        ''
      ],
      [
        'Object Key',
        'Type',
        'Subtype',
        'Tag',
        'External Id',
        'Description',
        # Disposition Update Columns
        'Disposition Date',
        'Disposition Type',
        'Sales Proceeds'
      ]
    ]
  end

  def column_styles
    [
      {:name => 'asset_id_col', :column => 0},
      {:name => 'asset_id_col', :column => 1},
      {:name => 'asset_id_col', :column => 2},
      {:name => 'asset_id_col', :column => 3},
      {:name => 'asset_id_col', :column => 4},
      {:name => 'asset_id_col', :column => 5},

      {:name => 'disposition_report_date', :column => 6},
      {:name => 'disposition_report', :column => 7},
      {:name => 'disposition_report_currency', :column => 8}
    ]
  end

  def column_widths
    # set specific width to last 4 columns to avoid cut-off text
    [nil] * 5 + 
    [20] * 4
  end

  def row_types
    [
      # Asset Id Block
      :string,
      :string,
      :string,
      :string,
      :string,
      :string,
      # Disposition Report Block
      :integer,
      :string,
      :integer
    ]
  end

  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super

    a << {:name => 'asset_id_col', :bg_color => "EBF1DE", :fg_color => '000000', :b => false, :alignment => { :horizontal => :center }, :locked => true}

    a << {:name => 'disposition_report', :bg_color => "F2F2F2", :alignment => { :horizontal => :center }, :locked => false }
    a << {:name => 'disposition_report_currency', :num_fmt => 5, :bg_color => "F2F2F2", :alignment => { :horizontal => :center }, :locked => false }
    a << {:name => 'disposition_report_date', :format_code => 'MM/DD/YYYY', :bg_color => "F2F2F2", :alignment => { :horizontal => :center } , :locked => false }

    a.flatten
  end

  def worksheet_name
    'Updates'
  end

  private

  def initialize(*args)
    super
  end

end
