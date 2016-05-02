require 'spec_helper'

describe Postgres::Clone::CommandResult do
  subject { Postgres::Clone::CommandResult }

  describe '#initialize' do
    let(:command_result) { subject.new(exit_code: 1, output: "\tThis is the output\n") }

    it 'assigns an exit code' do
      expect(command_result.exit_code).to be
    end

    it 'assigns output' do
      expect(command_result.output).to be
    end

    it 'strips whitespace from the output' do
      expect(command_result.output).to eq('This is the output')
    end
  end

  describe '#failed?' do
    context 'exit code is 0' do
      it 'returns false' do
        expect(subject.new(exit_code: 0, output: '').failed?).to eq(false)
      end
    end

    context 'exit code is a non-zero number' do
      it 'returns true' do
        expect(subject.new(exit_code: 1, output: '').failed?).to eq(true)
      end
    end

    context 'exit code is nil' do
      it 'returns true' do
        expect(subject.new(exit_code: nil, output: '').failed?).to eq(true)
      end
    end
  end

  describe '#success?' do
    context 'exit code is 0' do
      it 'returns true' do
        expect(subject.new(exit_code: 0, output: '').success?).to eq(true)
      end
    end

    context 'exit code is a non-zero number' do
      it 'returns true' do
        expect(subject.new(exit_code: 1, output: '').success?).to eq(false)
      end
    end

    context 'exit code is nil' do
      it 'returns false' do
        expect(subject.new(exit_code: nil, output: '').success?).to eq(false)
      end
    end
  end
end
