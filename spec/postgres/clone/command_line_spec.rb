require 'spec_helper'

describe Postgres::Clone::CommandLine do
  subject { Class.new { include Postgres::Clone::CommandLine }.new }

  describe '#build_command' do
    let(:command) { 'dummy-command' }

    context 'as self' do
      it 'builds the command without sudo' do
        expect(subject.build_command(command)).to eq(command)
      end
    end

    context 'as sudo' do
      it 'builds the command with sudo' do
        expect(subject.build_command(command, sudo: true)).to eq("sudo #{command}")
      end
    end

    context 'as user' do
      let(:user) { 'linus' }

      it 'builds the command with sudo -u <user>' do
        expect(subject.build_command(command, sudo: true, user: user)).to eq("sudo -u #{user} #{command}")
      end
    end
  end
end
