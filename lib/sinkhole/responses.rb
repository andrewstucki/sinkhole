module Sinkhole
  module Responses
    class SmtpResponse
      attr_reader :action

      def initialize(message="", opts={})
        options = {
          action: nil,
          separator: " ",
          object: nil
        }.merge(opts)
        @message = message
        @separator = options[:separator]
        @action = options[:action]
        @object = options[:object]
      end

      def status
        raise NotImplementedError
      end

      def self.status(num)
        send(:define_method, :status) do
          num
        end
      end

      def self.message(msg)
        send(:define_method, :message) do
          num
        end
      end

      def render
        "#{self.status}#{@separator}#{@message}\r\n"
      end

      def debug
        "#{self.status}#{@separator}#{@message} - #{@object}"
      end
    end

    class SystemStatus < SmtpResponse
      status 211
    end

    class HelpMessage < SmtpResponse
      status 214
    end

    class ServiceReady < SmtpResponse
      status 220
    end

    class ServiceClosingChannel < SmtpResponse
      status 221
    end

    class AuthenticationValidated < SmtpResponse
      status 235
    end

    class ActionCompleted < SmtpResponse
      status 250
    end

    class ForwardingNonLocal < SmtpResponse
      status 251
    end

    class AttemptingUnverifiedDelivery < SmtpResponse
      status 252
    end

    class AuthIncomplete < SmtpResponse
      status 334
    end

    class StartMailInput < SmtpResponse
      status 354
    end
  end
end

# 211 System status, or system help reply
# 214 Help message
#    (Information on how to use the receiver or the meaning of a
#    particular non-standard command; this reply is useful only
#    to the human user)
# 220 <domain> Service ready
# 221 <domain> Service closing transmission channel
# 250 Requested mail action okay, completed
# 251 User not local; will forward to <forward-path>
#    (See section 3.4)
# 252 Cannot VRFY user, but will accept message and attempt
#    delivery
#    (See section 3.5.3)
#
# 354 Start mail input; end with <CRLF>.<CRLF>