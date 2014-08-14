module Sinkhole
  module Errors
    class SmtpError < StandardError
      def initialize(object=nil, message=nil)
        super(message)
        @object = object
      end

      def status
        raise NotImplementedError
      end

      def self.status(num)
        send(:define_method, :status) do
          num
        end
      end

      def render
        "#{self.status} #{self.message}\r\n"
      end

      def debug
        "#{self.status} #{self.message} - #{@object}"
      end
    end

    class ServiceUnavailable < SmtpError
      status 421
    end

    class MailboxBusy < SmtpError
      status 450
    end

    class LocalProcessing < SmtpError
      status 451
    end

    class InsufficientSystemStorage < SmtpError
      status 452
    end

    class CommandNotRecognized < SmtpError
      status 500
    end

    class CommandSyntax < SmtpError
      status 501
    end

    class CommandNotImplemented < SmtpError
      status 502
    end

    class BadSequence < SmtpError
      status 503
    end

    class CommandParameterNotImplemented < SmtpError
      status 504
    end

    class AuthenticationRequired < SmtpError
      status 530
    end

    class InvalidAuth < SmtpError
      status 535
    end

    class MailboxUnavailable < SmtpError
      status 550
    end

    class UserNotLocal < SmtpError
      status 551
    end

    class ExceededStorageAllocation < SmtpError
      status 552
    end

    class MailboxNameNotAllowed < SmtpError
      status 553
    end

    class TransactionFailed < SmtpError
      status 554
    end
  end
end

# 421 <domain> Service not available, closing transmission channel
#    (This may be a reply to any command if the service knows it
#    must shut down)
# 450 Requested mail action not taken: mailbox unavailable
#    (e.g., mailbox busy)
# 451 Requested action aborted: local error in processing
# 452 Requested action not taken: insufficient system storage
# 500 Syntax error, command unrecognized
#    (This may include errors such as command line too long)
# 501 Syntax error in parameters or arguments
# 502 Command not implemented (see section 4.2.4)
# 503 Bad sequence of commands
# 504 Command parameter not implemented
# 550 Requested action not taken: mailbox unavailable
#    (e.g., mailbox not found, no access, or command rejected
#    for policy reasons)
# 551 User not local; please try <forward-path>
#    (See section 3.4)
# 552 Requested mail action aborted: exceeded storage allocation
# 553 Requested action not taken: mailbox name not allowed
#    (e.g., mailbox syntax incorrect)
# 554 Transaction failed  (Or, in the case of a connection-opening
#     response, "No SMTP service here")