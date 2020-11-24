# frozen_string_literal: true

module Ractor
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
      end
    end
  end
end
