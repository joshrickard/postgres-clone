require 'spec_helper'

describe Postgres::Clone::CommandLine do
  subject { Class.new { include Postgres::Clone::CommandLine }.new }

  describe '#build_command' do
    let(:command) { 'dummy-command' }

    context 'as self' do
      expect(subject.build_command(command)).to eq(command)
    end

    context 'as sudo' do
      expect(subject.build_command(command, sudo: true)).to eq("sudo #{command}")
    end

    context 'as user' do
      expect(subject.build_command(command, sudo: true, user: 'linus')).to eq("sudo -u #{user} #{command}")
    end
  end
end
