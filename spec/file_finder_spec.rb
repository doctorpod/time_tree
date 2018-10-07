require 'helper'

module TimeTree
  # rubocop:disable Metrics/BlockLength, Metrics/LineLength
  describe FileFinder do
    let(:tree) { double('ActivityTree', load: nil) }
    let(:line_parser) { double('LineParser', parse: nil) }
    let(:home) { ENV['HOME'] }

    subject(:parser) { described_class.new(tree, {}, line_parser) }

    describe '#find_path' do
      it 'finds a path' do
        parser.find_path(['/not/on/your/nelly', "#{home}/.bash_profile"]).should =~ /bash_profile/
      end

      it 'finds no path' do
        parser.find_path(['/not/on/your/nelly', '#/not/there']).should be false
      end
    end

    describe '#process_file' do
      context 'is a directory' do
        before do
          described_class.any_instance.stub(process_folder: true)
        end

        it 'returns true' do
          parser.process_file(fixtures).should be true
        end

        it 'calls #process_folder' do
          parser.should_receive(:process_folder).with(fixtures).once
          parser.process_file(fixtures)
        end
      end

      context 'is a file' do
        before do
          described_class.any_instance.stub(parse_line: true)
        end

        it 'returns true' do
          parser.process_file(fixtures('time.txt')).should be true
        end

        it 'calls LineParser.parse for each line of the file' do
          line_parser.should_receive(:parse).exactly(3).times
          parser.process_file(fixtures('time.txt'))
        end
      end

      context 'file or directory not found' do
        before do
          @result = parser.process_file('does/not/exist')
        end

        it 'returns false' do
          @result.should be false
        end

        it 'flags an error and sets object invalid' do
          expect(parser.errors.size).to eq 1
          parser.valid?.should be false
        end
      end
    end

    describe '#process_folder' do
      before do
        described_class.any_instance.stub(process_file: true)
      end

      it 'calls #process_file for each contained file' do
        parser.should_receive(:process_file).with(fixtures('time/jun1.txt')).once
        parser.should_receive(:process_file).with(fixtures('time/jun2.txt')).once
        parser.should_receive(:process_file).with(fixtures('time/jun3.txt')).once
        parser.process_folder(fixtures('time'))
      end

      it 'ignores files starting with dot' do
        File.open(fixtures('.a_dot_file'), 'w') { |f| f.write('foo') }
        parser.should_not_receive(:process_file).with(fixtures('.a_dot_file'))
        parser.process_folder(fixtures)
      end
    end
  end
  # rubocop:enable Metrics/BlockLength, Metrics/LineLength
end
