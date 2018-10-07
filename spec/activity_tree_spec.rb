require 'helper'

module TimeTree
  # rubocop:disable Metrics/BlockLength, Metrics/LineLength
  describe ActivityTree do
    subject { ActivityTree.new }

    before do
      subject.load(%w[foo bar baz], 9, 'did baz')
      subject.load(%w[foo bar baz], 1, nil)
      subject.load(%w[foo bar bam], 5, 'did some bam')
      subject.load(%w[blah], 11, 'did serious blah')
      subject.load(%w[blah], 1, 'did more blah')
    end

    it 'All should have 2 root activities' do
      subject.tree['All'][:children].size.should == 2
    end

    it 'foo should have 15 mins' do
      subject.tree['All'][:children]['foo'][:minutes].should == 15
    end

    it 'foo should have no descriptions' do
      subject.tree['All'][:children]['foo'][:descriptions].size.should == 0
    end

    it 'bar should have 15 mins' do
      subject.tree['All'][:children]['foo'][:children]['bar'][:minutes].should == 15
    end

    it 'baz should have 10 mins' do
      subject.tree['All'][:children]['foo'][:children]['bar'][:children]['baz'][:minutes].should == 10
    end

    it 'baz should have 1 description' do
      expect(subject.tree['All'][:children]['foo'][:children]['bar'][:children]['baz'][:descriptions].size).to eq 1
      expect(subject.tree['All'][:children]['foo'][:children]['bar'][:children]['baz'][:descriptions].first).to eq 'did baz'
    end

    it 'bam should have 5 mins' do
      subject.tree['All'][:children]['foo'][:children]['bar'][:children]['bam'][:minutes].should == 5
    end

    it 'blah should have 12 mins' do
      subject.tree['All'][:children]['blah'][:minutes].should == 12
    end

    it 'blah should have 2 descriptions' do
      expect(subject.tree['All'][:children]['blah'][:descriptions].size).to eq 2
      expect(subject.tree['All'][:children]['blah'][:descriptions].first).to eq 'did serious blah'
      expect(subject.tree['All'][:children]['blah'][:descriptions].last).to eq 'did more blah'
    end

    it 'blah should have no children' do
      subject.tree['All'][:children]['blah'][:children].size.should == 0
    end

    context 'formatting' do
      before { subject.process }

      it 'spacing driven by width of activities' do
        expect(subject.output[0]).to eq('All          27 min (0:27)')
        expect(subject.output[1]).to eq('  blah       12 min (0:12)  did serious blah - did more blah')
        expect(subject.output[2]).to eq('  foo        15 min (0:15)')
        expect(subject.output[3]).to eq('    bar      15 min (0:15)')
        expect(subject.output[4]).to eq('      bam     5 min (0:05)  did some bam')
        expect(subject.output[5]).to eq('      baz    10 min (0:10)  did baz')
      end
    end
  end
  # rubocop:enable Metrics/BlockLength, Metrics/LineLength
end
