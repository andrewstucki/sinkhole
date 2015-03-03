module Sinkhole
  module Commands
    class Mail < Command
      ensure_state :ehlo
      ensure_no_state :mail, "MAIL already given"
      ensure_args "MAIL requires arguments"

      def do_process
        from = parse_args
        raise Errors::MailboxUnavailable.new(from, "sender is unacceptable") unless @connection.callback :mail, from
        @connection.state << :mail
        Responses::ActionCompleted.new("OK", object: @args)
      end

      private

      def parse_args
        if @args.length == 2
          size_keyword, size = @args[1].split("=", 2)
          raise Errors::CommandSyntax.new(@args, "invalid parameters passed to MAIL") if size_keyword.upcase != "SIZE"
          raise Errors::ExceededStorageAllocation.new(@args, "size too big") if size.to_i > 35882577
        end
        from = @args[0]
        from_keyword, from_value = from.split(":", 2)
        return $1 if from_keyword.upcase == "FROM" && from_value =~ /<(.*)>/
        raise Errors::CommandSyntax.new(@args, "invalid parameters passed to MAIL")
      end
    end
  end
end