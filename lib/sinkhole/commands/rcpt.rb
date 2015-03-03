module Sinkhole
  module Commands
    class Rcpt < Command
      ensure_state :mail
      ensure_args "RCPT requires a specified recipient"

      def do_process
        to = parse_args
        raise Errors::MailboxUnavailable.new(to, "recipient is unacceptable") unless @connection.callback :rcpt, to
        @connection.state << :rcpt unless @connection.state.include?(:rcpt)
        Responses::ActionCompleted.new("OK", object: @args)
      end

      private

      def parse_args
        from = @args[0]
        from_keyword, from_value = from.split(":", 2)
        return $1 if from_keyword.upcase == "TO" && from_value =~ /<(.*)>/
        raise Errors::CommandSyntax.new(from, "invalid parameters passed to RCPT")
      end
    end
  end
end