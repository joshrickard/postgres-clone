require 'spec_helper'

describe Postgres::Clone::Logger do
  subject { Class.new { include Postgres::Clone::Logger }.new }
  let(:default_color) { Postgres::Clone::Logger::DEFAULT_COLOR }
  let(:message) { 'This is a test message' }

  describe '#log_message' do
    context 'using a header' do
      it 'prints a header before the message' do
        expect(STDOUT).to receive(:puts).with('HEADER')
        expect(STDOUT).to receive(:puts).with(Rainbow(message).color(default_color))

        subject.log_message(message, header: 'HEADER')
      end
    end

    context 'using a host name' do
      let(:host_name) { 'localhost' }

      it 'prints a host name within the message' do
        expect(STDOUT).to receive(:puts).once.with(
          Rainbow("[#{host_name}] #{message}").color(default_color)
        )

        subject.log_message(message, host_name: host_name)
      end
    end

    context 'using a specific color' do
      it 'uses the provided color' do
        expect(STDOUT).to receive(:puts).once.with(Rainbow(message).color(:red))
        subject.log_message(message, color: :red)
      end
    end

    context 'using defaults' do
      it 'does not print a header' do
        expect(STDOUT).to receive(:puts).once
        subject.log_message(message)
      end

      it 'prints the message as provided' do
        expect(STDOUT).to receive(:puts).once.with(Rainbow(message).color(default_color))
        subject.log_message(message)
      end
    end
  end
end
