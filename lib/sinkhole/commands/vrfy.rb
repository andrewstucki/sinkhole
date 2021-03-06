module Sinkhole
  module Commands
    class Vrfy < Command
      ensure_state :starttls
      ensure_state :auth
      ensure_args "VRFY requires a parameter"

      def do_process
        user = @connection.callback :vrfy, @args[0]
        raise Errors::MailboxNameNotAllowed.new(@args, "User ambiguous") unless user
        Responses::ActionCompleted.new(user)
      end
    end
  end
end