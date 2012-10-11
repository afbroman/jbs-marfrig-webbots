require_relative "../date_range_generator"

describe DateRangeGenerator do
  describe "#generate" do
    
    it "should generate a list of dates" do
      
      result = subject.generate "01/08/2010", "01/09/2010"
      result = result.map { |date| date.strftime("%d/%m/%Y") }

      result.should include("01/08/2010")
      result.should include("02/08/2010")
      result.should include("15/08/2010")
      result.should include("20/08/2010")
      result.should include("01/09/2010")
      result.should have(32).dates

    end

  end
end
