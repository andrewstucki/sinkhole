require 'sinkhole/commands/auth/login'
require 'sinkhole/commands/auth/plain'

# http://www.fehcom.de/qmail/smtpauth.html
module Sinkhole
  module Commands
    class Auth < Command
      ensure_state :starttls
      ensure_no_state :auth, "AUTH already issued"
      ensure_no_state :auth_plain, "AUTH already issued"
      ensure_no_state :auth_login, "AUTH already issued"
      ensure_args "AUTH scheme required"

      def do_process
        auth_scheme, credentials = get_auth_scheme
        if credentials.nil?
          @connection.state << auth_scheme.state
          return Responses::AuthIncomplete.new(auth_scheme.prompt)
        end
        if auth_scheme.check_credentials(@connection, credentials)
          @connection.state << :auth
          return Responses::AuthenticationValidated.new("authentication ok")
        else
          raise Errors::InvalidAuth.new(credentials, "invalid authentication")
        end
      end

      private

      def get_auth_scheme
        begin
          auth_klass = self.class.const_get(@args[0].downcase.capitalize)
          creds = @args[1..-1] if @args.length > 1
          [auth_klass, creds]
        rescue NameError
          raise Errors::CommandParameterNotImplemented.new(@args, "auth mechanism not available")
        end
      end

    end
  end
end