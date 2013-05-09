require 'time_tree/date_calculator'

module TimeTree
  describe DateCalculator do
    include DateCalculator
    
    describe "prev_weekday" do
      it "monday" do
        prev_weekday(Date.new(2013, 5, 5), :mon, 0).should == Date.new(2013, 4, 29)
      end

      it "tuesday" do
        prev_weekday(Date.new(2013, 5, 6), :tue, 0).should == Date.new(2013, 4, 30)
      end

      it "sunday" do
        prev_weekday(Date.new(2013, 5, 7), :sun, 0).should == Date.new(2013, 5, 5)
      end

      it "sunday prev week" do
        prev_weekday(Date.new(2013, 5, 8), :sun, 1).should == Date.new(2013, 4, 28)
      end

      it "tuesday prev prev week" do
        prev_weekday(Date.new(2013, 5, 9), :tue, 2).should == Date.new(2013, 4, 23)
      end
    end
  
    describe "next_weekday" do
      it "monday" do
        next_weekday(Date.new(2013, 5, 6), :mon, 0).should == Date.new(2013, 5, 13)
      end

      it "tuesday" do
        next_weekday(Date.new(2013, 5, 6), :tue, 0).should == Date.new(2013, 5, 7)
      end

      it "sunday" do
        next_weekday(Date.new(2013, 5, 7), :sun, 0).should == Date.new(2013, 5, 12)
      end

      it "sunday next week" do
        next_weekday(Date.new(2013, 5, 8), :sun, 1).should == Date.new(2013, 5, 19)
      end

      it "tuesday next next week" do
        next_weekday(Date.new(2013, 5, 9), :tue, 2).should == Date.new(2013, 5, 28)
      end
    end

    describe "date_between" do
      let(:jun1) { Date.new(2000, 6, 1) }
      let(:jun2) { Date.new(2000, 6, 2) }
      let(:jun3) { Date.new(2000, 6, 3) }

      it "between" do
        date_between?(jun2, jun1, jun3).should be_true
      end

      it "outside" do
        date_between?(jun1, jun2, jun3).should be_false
      end
    
      it "at start" do
        date_between?(jun1, jun1, jun3).should be_true
      end
    
      it "at end" do
        date_between?(jun3, jun1, jun3).should be_true
      end
    end

    describe "in_prev_week?" do
      let(:may7) { Date.new(2013, 5, 7) }
      let(:may1) { Date.new(2013, 5, 1) }
      
      it "within - zero count" do
        in_prev_week?(may7, 0, may7).should be_true
      end

      it "within - 1 count" do
        in_prev_week?(may1, 1, may7).should be_true
      end

      it "outside" do
        in_prev_week?(may7, 1, may7).should be_false
      end
    end
    
    describe"in_prev_month?" do
      let(:may31) { Date.new(2013, 5, 31) }
      let(:may7)  { Date.new(2013, 5, 7) }
      let(:may1)  { Date.new(2013, 5, 1) }
      let(:apr1)  { Date.new(2013, 4, 1) }
      
      it "within - zero count" do
        in_prev_month?(may1, 0, may7).should be_true
        in_prev_month?(may31, 0, may7).should be_true
      end

      it "within - 1 count" do
        in_prev_month?(apr1, 1, may7).should be_true
      end

      it "outside" do
        in_prev_month?(apr1, 0, may7).should be_false
      end
    end
  end
end