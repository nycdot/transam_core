require 'rails_helper'

RSpec.describe AssetDispositionUpdateJob, :type => :job do

  let(:test_asset) { create(:equipment_asset) }
  let(:test_org) { create(:organization_basic) }

  it '.run' do
    test_event = test_asset.disposition_updates.create!(attributes_for(:disposition_update_event, :organization_id => test_org.id))
    AssetDispositionUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.disposition_date).to eq(Date.today)
    expect(test_asset.disposition_type).to eq(test_event.disposition_type)
    expect(test_asset.service_status_type).to eq(ServiceStatusType.find_by(:code => 'D'))
  end

  it '.prepare' do
    test_asset.save!
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))

    expect(Rails.logger).to receive(:debug).with("Executing AssetDispositionUpdateJob at #{Time.now.to_s} for Asset #{test_asset.object_key}")
    AssetDispositionUpdateJob.new(test_asset.object_key).prepare
  end
end
