module Sinkhole
  module Commands
    class Help < Command
      def do_process
        Responses::HelpMessage.new(":(... y u no smtp?")
      end
    end
  end
end