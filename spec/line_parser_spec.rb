require 'helper'

# rubocop:disable Metrics/ModuleLength, Metrics/BlockLength, Metrics/LineLength
module TimeTree
  describe LineParser do
    let(:path) { 'my/nice/file.timetree' }
    let(:tree) { double('ActivityTree', load: nil) }

    subject(:parser) { described_class.new(tree, {}) }

    describe '#parse' do
      context 'date lines' do
        before do
          described_class.any_instance.stub(save_date: true)
        end

        context 'well formed date' do
          let(:good_date) { '2013/04/23 some comments' }

          it 'returns true' do
            parser.parse(path, good_date).should be true
          end
        end

        context 'malformed date' do
          let(:bad_date) { 'underpants/foo/bar bananas are fab' }

          it 'returns false' do
            parser.parse(path, bad_date).should be false
          end

          it 'logs an error' do
            parser.parse(path, bad_date)
            parser.errors.size.should == 1
          end
        end
      end

      context 'time lines' do
        before { parser.send(:save_date, '2013/01/02') }

        context 'normal activities' do
          it 'returns true and remains valid' do
            parser.parse(path, '1634 adm/foo/bar dhffhkdhsdhjdf').should be true
            parser.parse(path, '1635 adm/foo/bar dhffh kdh sdhjdf  ').should be true
            parser.parse(path, '1636    adm/foo/bar     dhffh kdh sdhjdf  ').should be true
            parser.parse(path, '1637 adm').should be true
            parser.parse(path, '1638 -').should be true
            parser.parse(path, '1639 - sdf sdfs sfsad').should be true
            parser.valid?.should be true
          end

          it 'calls ActivityTree#load after first line' do
            tree.should_receive(:load).with(%w[adm foo bar], 1, 'blart flange').once
            parser.parse(path, '1634 adm/foo/bar blart flange')
            parser.parse(path, '1635 -')
          end

          it 'handles absent descriptions' do
            tree.should_receive(:load).with(%w[adm foo bar], 1, nil).once
            parser.parse(path, '1734 adm/foo/bar')
            parser.parse(path, '1735 -')
          end

          it 'flags invalid times' do
            parser.parse(path, '2435 - df sdfsdg').should be false
            parser.parse(path, '2x3d - df sdfsdg').should be false
            parser.valid?.should be false
          end

          it 'flags non-advancing times' do
            parser.parse(path, '1253 - df sdfsdg').should be true
            parser.parse(path, '1253 - df sdfsdg').should be false
            parser.valid?.should be false
          end
        end
      end

      context 'dash for activity' do
        it 'returns true and remains valid' do
          parser.parse(path, '1634 -').should be true
          parser.valid?.should be true
        end

        it 'does not call ActivityTree#load after first line' do
          tree.should_not_receive(:load).with(%w[-], 1)
          parser.parse(path, '1634 -')
          parser.parse(path, '1635 foo')
        end
      end

      context 'ampersand for activity (ditto last activity)' do
        before { parser.send(:save_date, '2013/01/02') }

        it 'returns true and remains valid' do
          parser.parse(path, '1634 &').should be true
          parser.valid?.should be true
        end

        context 'Previous activity immediately before' do
          it 'calls ActivityTree#load with previous activity' do
            tree.should_receive(:load).with(%w[foo], 1, nil).twice
            parser.parse(path, '1634 foo')
            parser.parse(path, '1635 &')
            parser.parse(path, '1636 bar')
          end
        end

        context 'Previous activity separated by -' do
          it 'calls ActivityTree#load with previous activity' do
            tree.should_receive(:load).with(%w[foo], 1, nil).twice
            parser.parse(path, '1633 foo')
            parser.parse(path, '1634 -')
            parser.parse(path, '1635 &')
            parser.parse(path, '1636 bar')
          end
        end
      end

      context 'comment lines' do
        it 'should return true' do
          parser.parse(path, '# a comment').should be true
        end

        it 'should not log errors' do
          parser.parse(path, '# a comment')
          parser.errors.size.should == 0
        end
      end
    end

    describe 'midnight edge case' do
      context 'no previous mins' do
        it 'returns 0 mins' do
          parser.send(:parse_mins, '0000', path).should == 0
        end
      end

      context 'previous mins' do
        it 'returns 1440 mins (1 day)' do
          parser.parse(path, '2359 foo')
          parser.send(:parse_mins, '0000', path).should == 1440
        end
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength, Metrics/BlockLength, Metrics/LineLength
