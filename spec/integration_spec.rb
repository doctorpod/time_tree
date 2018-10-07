require 'helper'

module TimeTree
  # rubocop:disable Metrics/BlockLength
  describe 'Integration' do
    let(:tree) { ActivityTree.new }

    it 'nominal' do
      parser = FileFinder.new(tree, {})
      parser.process_file(fixtures('time'))
      tree.process
      tree.output[0].should =~ /All +6 min/
      tree.output[1].should =~ /jun1stuff +1 min \(0:01\) +jun1/
      tree.output[2].should =~ /jun2stuff +2 min \(0:02\) +jun2/
      tree.output[3].should =~ /jun3stuff +3 min \(0:03\) +jun3/
      tree.output.size.should == 4
    end

    it 'specific date' do
      parser = FileFinder.new(tree, date: '1975/06/02')
      parser.process_file(fixtures('time'))
      tree.process
      tree.output[0].should =~ /All +2 min/
      tree.output[1].should =~ /jun2stuff +2 min/
      tree.output.size.should == 2
    end

    it 'date range' do
      parser = FileFinder.new(tree, range: '1975/06/02:1975/06/03')
      parser.process_file(fixtures('time'))
      tree.process
      tree.output[0].should =~ /All +5 min/
      tree.output[1].should =~ /jun2stuff +2 min/
      tree.output[2].should =~ /jun3stuff +3 min/
      tree.output.size.should == 3
    end

    it 'today' do
      parser = FileFinder.new(tree, today: true)
      parser.process_file(fixtures('time'))
      tree.process
      tree.output.size.should == 0
    end

    it 'yesterday' do
      parser = FileFinder.new(tree, yesterday: true)
      parser.process_file(fixtures('time'))
      tree.process
      tree.output.size.should == 0
    end

    it 'this week' do
      parser = FileFinder.new(tree, week: 0)
      parser.process_file(fixtures('time'))
      tree.process
      tree.output.size.should == 0
    end

    it 'last week' do
      parser = FileFinder.new(tree, week: 1)
      parser.process_file(fixtures('time'))
      tree.process
      tree.output.size.should == 0
    end

    it 'this month' do
      parser = FileFinder.new(tree, month: 0)
      parser.process_file(fixtures('time'))
      tree.process
      tree.output.size.should == 0
    end

    it 'last month' do
      parser = FileFinder.new(tree, month: 1)
      parser.process_file(fixtures('time'))
      tree.process
      tree.output.size.should == 0
    end

    it 'filter' do
      parser = FileFinder.new(tree, filter: ['jun2stuff'])
      parser.process_file(fixtures('time'))
      tree.process
      tree.output[0].should =~ /All +2 min/
      tree.output[1].should =~ /jun2stuff +2 min/
      tree.output.size.should == 2
    end
  end
  # rubocop:enable Metrics/BlockLength
end
