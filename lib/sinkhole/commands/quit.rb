module Sinkhole
  module Commands
    class Quit < Command
      ensure_no_args

      def do_process
        Responses::ServiceClosingChannel.new("closing connection", action: :quit)
      end
    end
  end
end