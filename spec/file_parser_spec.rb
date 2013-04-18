require 'time_log/file_parser'

require 'helper'

module TimeLog
  describe FileParser do
    let(:tree) { mock('ActivityTree', :load => nil) }
    let(:parser) { FileParser.new(tree) }
    
    describe "#process_file" do
      context "file found" do
        before do
          FileParser.any_instance.stub(:parse_line => true)
        end
        
        it "returns true" do
          parser.process_file(fixtures('time.txt')).should be_true
        end
        
        it "calls process_line for each line of the file" do
          parser.should_receive(:parse_line).twice
          parser.process_file(fixtures('time.txt'))
        end
      end
      
      context "file not found" do
        before do
          @result = parser.process_file('does/not/exist')
        end
        
        it "returns false" do
          @result.should be_false
        end
        
        it "flags an error and sets object invalid" do
          parser.errors.size.should == 1
          parser.valid?.should be_false
        end
      end
    end
    
    describe '#parse_line' do
      context "normal lines" do
        it "returns true and remains valid" do
          parser.parse_line("1634 adm/foo/bar dhffhkdhsdhjdf").should be_true
          parser.parse_line("1635 adm/foo/bar dhffh kdh sdhjdf  ").should be_true
          parser.parse_line("1636    adm/foo/bar     dhffh kdh sdhjdf  ").should be_true
          parser.parse_line("1637 adm").should be_true
          parser.parse_line("1638 -").should be_true
          parser.parse_line("1639 - sdf sdfs sfsad").should be_true
          parser.valid?.should be_true
        end
        
        it "calls ActivityTree#load after first line" do
          tree.should_receive(:load).with(%w{adm foo bar}, 1).once
          parser.parse_line("1634 adm/foo/bar dhffhkdhsdhjdf")
          parser.parse_line("1635 -")
        end
      end

      it "flags invalid times" do
        parser.parse_line("2435 - df sdfsdg").should be_false
        parser.parse_line("2x3d - df sdfsdg").should be_false
        parser.valid?.should be_false
      end

      it "flags non-advancing times" do
        parser.parse_line("1253 - df sdfsdg").should be_true
        parser.parse_line("1253 - df sdfsdg").should be_false
        parser.valid?.should be_false
      end
    end
  end
end