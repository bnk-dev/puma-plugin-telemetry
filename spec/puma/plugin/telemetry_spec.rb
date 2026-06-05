# frozen_string_literal: true

module Puma
  class Plugin
    RSpec.describe Telemetry do
      it 'has a version number' do
        expect(Telemetry::VERSION).not_to be_nil
      end

      describe '.config' do
        it 'has a default configuration' do
          expect(described_class.config).not_to be_nil
        end
      end

      describe '.build' do
        let(:default_telemetry) do
          {
            'workers.booted' => 1,
            'workers.total' => 1,
            'workers.max_threads' => 0,
            'workers.requests_count' => 0,
            'workers.spawned_threads' => 0,
            'queue.backlog' => 0,
            'queue.capacity' => 0
          }
        end

        it 'returns default telemetry hash' do
          allow(::Puma).to receive(:stats_hash).and_return({})
          expect(described_class.build).to eq(default_telemetry)
        end
      end

      context 'when Plugin' do
        subject(:plugin) { Puma::Plugins.find('telemetry').new }

        describe 'plugin registration' do
          it 'works' do
            expect(plugin).to respond_to(:start)
          end
        end

        describe '.call' do
          let(:config) do
            Telemetry::Config.new.tap do |c|
              c.targets = targets
            end
          end

          let(:targets) { [instance_spy(Proc), instance_spy(Proc)] }
          let(:telemetry) { { foo: :bar } }

          before do
            allow(described_class).to receive(:config).and_return(config)
          end

          it 'executes first target with telemetry' do
            plugin.call(telemetry)
            expect(targets[0]).to have_received(:call).with(telemetry)
          end

          it 'executes last target with telemetry' do
            plugin.call(telemetry)
            expect(targets[1]).to have_received(:call).with(telemetry)
          end

          it 'returns list of targets called' do
            expect(plugin.call(telemetry)).to eq(targets)
          end
        end

        describe '#run!' do
          let(:log_writer) do
            instance_double(::Puma::LogWriter, debug: nil, error: nil, unknown_error: nil)
          end
          let(:error) { StandardError.new('boom') }

          before do
            allow(described_class).to receive(:config).and_return(Telemetry::Config.new)
            allow(described_class).to receive(:build).and_return({})
            allow(plugin).to receive(:log_writer).and_return(log_writer)
            allow(plugin).to receive(:call).and_raise(error)
            # `loop` rescues StopIteration, so raising it from the `ensure`
            # sleep lets us exit the otherwise-infinite loop after one pass.
            allow(plugin).to receive(:sleep).and_raise(StopIteration)
          end

          it 'logs publish errors without exiting the process' do
            plugin.run!

            # `log_writer.error` calls `exit 1`; it must not be used here.
            expect(log_writer).not_to have_received(:error)
            expect(log_writer).to have_received(:unknown_error).with(error, nil, 'plugin=telemetry')
          end
        end
      end
    end
  end
end
