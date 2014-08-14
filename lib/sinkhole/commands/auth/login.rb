require 'base64'

module Sinkhole
  module Commands
    class Auth < Command
      class Login
        USERNAME_BASE64 = "VXNlcm5hbWU6"
        PASSWORD_BASE64 = "UGFzc3dvcmQ6"

        class << self
          def prompt
            USERNAME_BASE64
          end

          def state
            :auth_login
          end

          def check_credentials(connection, creds)
            raise Errors::InvalidAuth.new(creds, "invalid authentication") if creds.length > 2
            user = convert_line creds[0]
            pass = convert_line creds[1]
            connection.callback :auth, user, pass
          end

          def process(connection, line)
            value = convert_line(line)
            if connection.username
              username = connection.username
              connection.username = nil
              connection.state.delete state
              if connection.callback :auth, username, value
                connection.state << :auth
                return Responses::AuthenticationValidated.new("authentication ok")
              else
                return Errors::InvalidAuth.new(line, "invalid authentication")
              end
            else
              connection.username = value
              return Responses::AuthIncomplete.new(PASSWORD_BASE64)
            end
          end

          private

          def convert_line(line)
            Base64.decode64(line)
          end
        end
      end
    end
  end
end