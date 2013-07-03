require 'time_tree/activity_tree'

module TimeTree
  describe ActivityTree do
    let(:tree) { ActivityTree.new }

    before do
      tree.load(%w{foo bar baz}, 9, 'did baz')
      tree.load(%w{foo bar baz}, 1, nil)
      tree.load(%w{foo bar bam}, 5, 'did some bam')
      tree.load(%w{blah}, 11, 'did serious blah')
      tree.load(%w{blah}, 1, 'did more blah')
    end
      
    it "All should have 2 root activities" do  
      tree.activities['All'][:children].size.should == 2
    end
    
    it "foo should have 15 mins" do
      tree.activities['All'][:children]['foo'][:minutes].should == 15
    end

    it "foo should have no descriptions" do
      tree.activities['All'][:children]['foo'][:descriptions].size.should == 0
    end

    it "bar should have 15 mins" do
      tree.activities['All'][:children]['foo'][:children]['bar'][:minutes].should == 15
    end

    it "baz should have 10 mins" do
      tree.activities['All'][:children]['foo'][:children]['bar'][:children]['baz'][:minutes].should == 10
    end

    it "baz should have 1 description" do
      tree.activities['All'][:children]['foo'][:children]['bar'][:children]['baz'][:descriptions].size.should == 1
      tree.activities['All'][:children]['foo'][:children]['bar'][:children]['baz'][:descriptions].first.should == 'did baz'
    end

    it "bam should have 5 mins" do
      tree.activities['All'][:children]['foo'][:children]['bar'][:children]['bam'][:minutes].should == 5
    end

    it "blah should have 12 mins" do
      tree.activities['All'][:children]['blah'][:minutes].should == 12
    end

    it "blah should have 2 descriptions" do
      tree.activities['All'][:children]['blah'][:descriptions].size.should == 2
      tree.activities['All'][:children]['blah'][:descriptions].first.should == 'did serious blah'
      tree.activities['All'][:children]['blah'][:descriptions].last.should == 'did more blah'
    end

    it "blah should have no children" do
      tree.activities['All'][:children]['blah'][:children].size.should == 0
    end
    
    it "should print" do
      tree.process
      tree.print
    end
  end
end