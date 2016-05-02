require 'spec_helper'

describe Postgres::Clone::LocalCommands do
  subject { Class.new { include Postgres::Clone::LocalCommands }.new }

  describe '#run_local' do
    it 'returns a CommandResult' do
      expect(subject.run_local('echo').is_a?(Postgres::Clone::CommandResult)).to eq(true)
    end
  end

  describe '#sudo_local' do
    it 'executes run_local with sudo' do
      expect(subject).to receive(:run_local).with('command', sudo: true, user: nil)
      expect(subject.sudo_local('command'))
    end
  end
end
