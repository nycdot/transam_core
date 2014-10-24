require 'rails_helper'

RSpec.describe StraightLineEstimationCalculator, :type => :calculator do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  class Vehicle < Asset; end

  before(:each) do
    @organization = create(:organization)
    @test_asset = create(:buslike_asset, :organization => @organization)
    @policy = create(:policy, :organization => @organization)
    @policy_item = create(:policy_item, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)
    @condition_update_event = @test_asset.condition_updates.create(attributes_for(:test_condition_update_event))
  end

  let(:test_calculator) { StraightLineEstimationCalculator.new }

  describe '#calculate (estimated condition rating)' do

    it 'calculates' do
      expect(test_calculator.calculate(@test_asset)).to eq(2)
    end

    it 'calculates when no condition update event' do
      @test_asset.condition_updates.destroy_all
      expect(test_calculator.calculate(@test_asset)).to eq(2.08)
    end

    it 'is always greater than or equal to min rating' do
      # set age of asset very low to get a high rate of change
      # calculations will go below min but min should be returned
      @test_asset.manufacture_year = (Date.today - 1.years).year
      @test_asset.save

      expect(test_calculator.calculate(@test_asset)).to be >= ConditionType.min_rating
    end

    # asset always declines in rating
    it 'is always less than max rating' do
      expect(test_calculator.calculate(@test_asset)).to be < ConditionType.max_rating
    end

  end

  describe '#last_servicable year' do
    it 'calculates' do
      expect(test_calculator.last_servicable_year(@test_asset)).to eq(2025)
    end

    it 'is not greater than max life year' do
      max_life_year = @test_asset.in_service_date.year + @test_asset.policy_rule.max_service_life_years
      expect(test_calculator.last_servicable_year(@test_asset)).to be < max_life_year
    end

    it 'is greater than in service year' do
      expect(test_calculator.last_servicable_year(@test_asset)).to be > @test_asset.in_service_date.year
    end
  end

end