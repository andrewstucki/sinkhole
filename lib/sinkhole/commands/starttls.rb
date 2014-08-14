module Sinkhole
  module Commands
    class Starttls < Command
      ensure_no_args
      ensure_state :ehlo
      ensure_no_state :starttls, "TLS Already negotiated"

      def do_process
        @connection.state << :starttls
        Responses::ServiceReady.new("Start TLS negotiation.", action: :starttls)
      end
    end
  end
end