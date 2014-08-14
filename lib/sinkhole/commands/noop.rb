module Sinkhole
  module Commands
    class Noop < Command
      ensure_no_args

      def do_process
        Responses::ActionCompleted.new("OK")
      end
    end
  end
end