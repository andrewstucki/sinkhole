module Sinkhole
  module Commands
    class Data < Command
      ensure_state :mail
      ensure_state :rcpt
      ensure_no_args

      def do_process
        # want to throw the data callback when make pipelined
        @connection.state << :data
        @connection.reset_databuffer
        Responses::StartMailInput.new("Start mail input; end with <CRLF>.<CRLF>")
      end

      def self.process(connection, line)
        if line == "."
          if connection.databuffer.length > 0
            connection.callback :data_chunk, connection.databuffer
            connection.databuffer.clear
          end

          connection.state.delete :data
          connection.state.delete :mail
          connection.state.delete :rcpt
          if connection.callback :message
            return Responses::ActionCompleted.new("OK")
          else
            return Errors::TransactionFailed.new(line, "Message was rejected")
          end
        else
          # slice off leading . if any
          line.slice!(0...1) if line[0] == ?.
          connection.databuffer << line
          if connection.databuffer.length > 4096
            connection.callback :data_chunk, connection.databuffer
            connection.databuffer.clear
          end
          return nil
        end
      end
    end
  end
end