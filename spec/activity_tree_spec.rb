require 'time_log/activity_tree'

module TimeLog
  describe ActivityTree do
    let(:tree) { ActivityTree.new }

    before do
      tree.load(%w{foo bar baz}, 10)
      tree.load(%w{foo bar bam}, 5)
      tree.load(%w{blah}, 12)
    end
      
    it "should have 2 root activities" do  
      tree.activities['All'][:children].size.should == 2
    end
    
    it "foo should have 15 mins" do
      tree.activities['All'][:children]['foo'][:minutes].should == 15
    end

    it "bar should have 15 mins" do
      tree.activities['All'][:children]['foo'][:children]['bar'][:minutes].should == 15
    end

    it "baz should have 10 mins" do
      tree.activities['All'][:children]['foo'][:children]['bar'][:children]['baz'][:minutes].should == 10
    end

    it "bam should have 5 mins" do
      tree.activities['All'][:children]['foo'][:children]['bar'][:children]['bam'][:minutes].should == 5
    end

    it "blah should have 12 mins" do
      tree.activities['All'][:children]['blah'][:minutes].should == 12
    end

    it "blah should have no children" do
      tree.activities['All'][:children]['blah'][:children].size.should == 0
    end
    
    it "should print" do
      tree.print
    end
  end
end