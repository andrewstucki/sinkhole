module Sinkhole
  module Commands
    class Auth < Command
      class Plain
        class << self
          def prompt
            nil
          end

          def state
            :auth_plain
          end

          def check_credentials(connection, creds)
            raise Errors::InvalidAuth.new(creds, "invalid authentication") if creds.length > 1
            user, pass = parse_creds(creds.first)
            connection.callback :auth, user, pass
          end

          def process(connection, line)
            user, pass = parse_creds(line)
            connection.state.delete state
            if connection.callback :auth, user, pass
              connection.state << :auth
              return Responses::AuthenticationValidated.new("authentication ok")
            end
            return Errors::InvalidAuth.new(line, "invalid authentication")
          end

          private

          def parse_creds(creds)
            plain_creds = creds.unpack("m").first
            _, user, pass = plain_creds.split("\000")
            [user, pass]
          end
        end
      end
    end
  end
end