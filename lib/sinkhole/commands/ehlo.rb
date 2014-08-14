module Sinkhole
  module Commands
    class Ehlo < Command
      def do_process
        @connection.reset_state
        @connection.state << :ehlo
        response = []
        response << Responses::ActionCompleted.new("#{@connection.domain} at your service, [#{@connection.peer}]", separator: "-")
        response << Responses::ActionCompleted.new("SIZE 35882577", separator: "-")
        response << Responses::ActionCompleted.new("8BITMIME", separator: "-")
        response << Responses::ActionCompleted.new("STARTTLS", separator: "-")
        response << Responses::ActionCompleted.new("AUTH LOGIN PLAIN", separator: "-")
        # response << Responses::ActionCompleted.new("ENHANCEDSTATUSCODES", separator: "-")
        # response << Responses::ActionCompleted.new("PIPELINING", separator: "-")
        # response << Responses::ActionCompleted.new("CHUNKING", separator: "-")
        response << Responses::ActionCompleted.new("SMTPUTF8")
        response
      end
    end
  end
end

# 250-SIZE 35882577
# 250-8BITMIME
# 250-STARTTLS
# 250-AUTH LOGIN PLAIN XOAUTH XOAUTH2 PLAIN-CLIENTTOKEN
# 250-ENHANCEDSTATUSCODES
# 250-PIPELINING
# 250-CHUNKING
# 250 SMTPUTF8