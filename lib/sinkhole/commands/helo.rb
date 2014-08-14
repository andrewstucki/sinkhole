module Sinkhole
  module Commands
    class Helo < Command
      def do_process
        @connection.reset_state
        @connection.state << :ehlo
        Responses::ActionCompleted.new("#{@connection.domain} at your service")
      end
    end
  end
end