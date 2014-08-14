module Sinkhole
  module Commands
    class Rset < Command
      ensure_no_args

      def do_process
        @connection.reset_state
        Responses::ActionCompleted.new("Flushed", action: :reset)
      end
    end
  end
end