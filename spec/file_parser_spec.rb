require 'time_log/file_parser'
require 'helper'

module TimeLog
  describe FileParser do
    let(:tree) { mock('ActivityTree', :load => nil) }
    let(:parser) { FileParser.new(tree, {}) }

    describe "#process_file" do
      context "is a directory" do
        before do
          FileParser.any_instance.stub(:process_folder => true)
        end

        it "returns true" do
          parser.process_file(fixtures).should be_true
        end

        it "calls #process_folder" do
          parser.should_receive(:process_folder).with(fixtures).once
          parser.process_file(fixtures)
        end
      end

      context "is a file" do
        before do
          FileParser.any_instance.stub(:parse_line => true)
        end

        it "returns true" do
          parser.process_file(fixtures('time.txt')).should be_true
        end

        it "calls process_line for each line of the file" do
          parser.should_receive(:parse_line).exactly(3).times
          parser.process_file(fixtures('time.txt'))
        end
      end

      context "file or directory not found" do
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

    describe "#process_folder" do
      before do
        FileParser.any_instance.stub(:process_file => true)
      end

      it "calls #process_file for each contained file" do
        parser.should_receive(:process_file).with(fixtures('time/jun1.txt')).once
        parser.should_receive(:process_file).with(fixtures('time/jun2.txt')).once
        parser.should_receive(:process_file).with(fixtures('time/jun3.txt')).once
        parser.process_folder(fixtures('time'))
      end

      it "ignores files starting with dot" do
        File.open(fixtures('.a_dot_file'), 'w') {|f| f.write('foo')}
        parser.should_not_receive(:process_file).with(fixtures('.a_dot_file'))
        parser.process_folder(fixtures)
      end
    end

    describe "#parse_line" do
      before do
        parser.set_file('my_file.txt')
      end

      context "date lines" do
        before do
          FileParser.any_instance.stub(:set_date => true)
        end

        context "well formed date" do
          let(:good_date) { '2013/04/23 some comments' }

          it "returns true" do
            parser.parse_line(good_date).should be_true
          end

          it "calls set_date" do
            parser.should_receive(:set_date).once
            parser.parse_line(good_date)
          end
        end

        context "malformed date" do
          let(:bad_date) { '201b/foo/bar' }

          it "returns false" do
            parser.parse_line(bad_date).should be_false
          end

          it "does not call set_date" do
            parser.should_not_receive(:set_date)
            parser.parse_line(bad_date)
          end

          it "logs an error" do
            parser.parse_line(bad_date)
            parser.errors.size.should == 1
          end
        end
      end

      context "time lines" do
        before do
          parser.set_date('2013/01/02')
        end

        context "normal activities" do
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

      context "dash for activity" do
        it "returns true and remains valid" do
          parser.parse_line("1634 -").should be_true
          parser.valid?.should be_true
        end

        it "does not call ActivityTree#load after first line" do
          tree.should_not_receive(:load).with(%w{-}, 1)
          parser.parse_line("1634 -")
          parser.parse_line("1635 foo")
        end
      end

      context "comment lines" do
        it "should return true" do
          parser.parse_line("# a comment").should be_true
        end

        it "should not log errors" do
          parser.parse_line("# a comment")
          parser.errors.size.should == 0
        end
      end
    end

    describe "#selected?" do
      it "should be true if no date selectors" do
        parser.selected?('2013/01/01', {:bish => true, :bosh => :tigers}).should be_true
      end

      context "today" do
        let(:options) { {:today => true} }

        it "should be true if date is today" do
          parser.selected?(Time.now.strftime("%Y/%m/%d"), options).should be_true
        end

        it "should be false if date is not today" do
          parser.selected?('1962/01/03', '', options).should be_false
        end
      end

      context "yesterday" do
        let(:options) { {:yesterday => true} }

        it "should be true if date is yesterday" do
          parser.selected?((Time.now-(24*60*60)).strftime("%Y/%m/%d"), options).should be_true
        end

        it "should be false if date is not yesterday" do
          parser.selected?('1962/01/03', '', options).should be_false
        end
      end
      
      context "week" do
      end
      
      context "month" do
      end

      context "specific date" do
        let(:options) { {:date => '2012/01/01'} }

        it "should be true if date matches" do
          parser.selected?('2012/01/01', options).should be_true
        end

        it "should be false if date does not match" do
          parser.selected?('1962/01/03', '', options).should be_false
        end
      end

      context "date range" do
        let(:options) { {:range => '2012/01/01:2012/01/02'} }

        it "should be true if date within" do
          parser.selected?('2012/01/01', options).should be_true
          parser.selected?('2012/01/02', options).should be_true
        end

        it "should be false if date outside" do
          parser.selected?('1962/01/03', '', options).should be_false
        end
      end
      
      context "filter" do
        it "finds a hit" do
          parser.selected?('1962/01/03', 'foo/bar', {:filter => ['foo', 'boo']}).should be_true
        end

        it "finds no hit" do
          parser.selected?('1962/01/03', 'foo/bar', {:filter => ['blork', 'flange']}).should be_false
        end
      end
    end
  end
end
