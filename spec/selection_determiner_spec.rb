require 'helper'

module TimeTree
  # rubocop:disable Metrics/BlockLength
  describe SelectionDeterminer do
    subject { SelectionDeterminer.selected?(date, activities, options) }

    let(:activities) { '' }

    shared_examples :date_option do |option, option_value, matching_date|
      context "with '#{option}' option" do
        let(:options) { { option => option_value } }

        context "entry date matches #{option}" do
          let(:date) { matching_date }
          it { expect(subject).to be true }
        end

        context "entry date does not match #{option}" do
          let(:date) { '2000/01/01' }
          it { expect(subject).to be false }
        end
      end
    end

    describe '.selected?' do
      context 'with no date options' do
        let(:date) { '2013/01/01' }
        let(:options) { { bish: true, bosh: false } }
        it { expect(subject).to be true }
      end

      context 'with date options' do
        it_behaves_like :date_option, :today, true,
                        Time.now.strftime('%Y/%m/%d')
        it_behaves_like :date_option, :yesterday, true,
                        (Time.now - (24 * 60 * 60)).strftime('%Y/%m/%d')
        it_behaves_like :date_option, :date, '2012/01/01', '2012/01/01'
        it_behaves_like :date_option, :range, '2012/01/01:2012/01/02',
                        '2012/01/01'
      end

      context 'week' do
        pending
      end

      context 'month' do
        pending
      end

      context 'filter' do
        let(:date) { '1962/01/03' }
        let(:activities) { 'foo/bar' }

        context 'finds a hit' do
          let(:options) { { filter: %w[foo boo] } }
          it { expect(subject).to be true }
        end

        context 'finds no hit' do
          let(:options) { { filter: %w[bork flange] } }
          it { expect(subject).to be false }
        end
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
