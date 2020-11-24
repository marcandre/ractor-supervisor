# frozen_string_literal: true

class Ractor
  class Supervisor
    RSpec.describe Server do
      context 'for a class including Server' do
        subject { MultiplierServer::Client }

        its(:ancestors) { is_expected.to start_with(
          MultiplierServer::Client,
          MultiplierServer::Client::ServerCalls,
          Server::Client
        ) }
      end

      context 'for a class including Server' do
        subject { AfineServer::Client }

        its(:ancestors) { is_expected.to start_with(
          AfineServer::Client,
          AfineServer::Client::ServerCalls,
          MultiplierServer::Client,
          MultiplierServer::Client::ServerCalls,
          Server::Client
        ) }

        it 'links back to the server class' do
          expect(AfineServer::Client::Server).to eq(AfineServer)
        end
      end

      context 'for an instance of AfineServer' do
        subject(:client) { AfineServer::Client.new(3, offset: 42) }

        it 'can be shared' do
          expect(client.transform(2)).to eq(2*3 + 42)

          r = Ractor.new(client) do |client|
            Ractor.yield :ready
            a = client.transform(3)
            Ractor.yield :done
            Ractor.yield :ready
            b = client.transform(3)
            [a, b]
          end
          r.take # => :ready
          r.take # => :done
          client.offset = 100
          client.factor = 5
          expect(client.transform(2)).to eq(2*5 + 100)
          r.take # => :ready
          expect(r.take).to eq [3*3 + 42, 3*5 + 100]
        end

        it 'executes async calls asynchroneously' do
          expect { client.wait_sync(0.2)  }.to change { Time.now }.by(be > 0.1)
          expect { client.wait_async(0.2) }.to change { Time.now }.by(be < 0.1)
        end
      end
    end
  end
end
