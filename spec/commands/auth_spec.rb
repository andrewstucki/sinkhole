require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/auth'

class Sinkhole::Commands::Auth
  class Foo
  end
end

describe Sinkhole::Commands::Auth do
  it_ensures_states(:starttls)
  it_ensures_not_states(:auth_plain, :auth_login, :auth)
  it_ensures_arguments_present

  subject do
    connection = mock()
    connection.stubs(:state).returns([:ehlo])
    Sinkhole::Commands.new(["FOO randomstringhere"], connection)
  end

  context "when processing" do
    context "when determining the auth scheme" do
      it "throws a CommandParameterNotImplemented error when there is an invalid auth type"
      it "gets the auth scheme used by name"
    end

    context "when checking credentials" do
      it "returns an AuthIncomplete response when no credentials are provided"
      it "throws an InvalidAuth error when the credentials are invalid"
      it "goes into an authenticated state when the credentials are valid"
    end
  end
  # def do_process
  #   auth_scheme, credentials = get_auth_scheme
  #   if credentials.nil?
  #     @connection.state << auth_scheme.state
  #     return Responses::AuthIncomplete.new(auth_scheme.prompt)
  #   end
  #   if auth_scheme.check_credentials(@connection, credentials)
  #     @connection.state << :auth
  #     return Responses::AuthenticationValidated.new("authentication ok")
  #   else
  #     raise Errors::InvalidAuth.new(credentials, "invalid authentication")
  #   end
  # end
  #
  # private
  #
  # def get_auth_scheme
  #   begin
  #     auth_klass = self.class.const_get(@args[0].downcase.capitalize)
  #     creds = @args[1..-1] if @args.length > 1
  #     [auth_klass, creds]
  #   rescue NameError
  #     raise Errors::CommandParameterNotImplemented.new(@args, "auth mechanism not available")
  #   end
  # end
end