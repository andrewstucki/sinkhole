require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/auth'

class Sinkhole::Commands::Auth
  class Foo
    def self.state
      :foo
    end

    def self.prompt
      "foo"
    end
  end
end

describe Sinkhole::Commands::Auth do
  it_ensures_states(:starttls)
  it_ensures_not_states(:auth_plain, :auth_login, :auth)
  it_ensures_arguments_present

  let(:state) do
    mock()
  end

  let(:connection) do
    connection = mock()
    connection.stubs(:state).returns([:ehlo])
    connection
  end

  before do
    connection.stubs(:state).returns(state)
  end

  context "when processing" do
    context "when determining the auth scheme" do
      it "throws a CommandParameterNotImplemented error when there is an invalid auth type" do
        cmd = Sinkhole::Commands::Auth.new(["BAR"], connection)
        expect do
          cmd.do_process
        end.to raise_error(Sinkhole::Errors::CommandParameterNotImplemented)
      end

      it "gets the auth scheme used by name" do
        state.expects(:<<).with(:foo)
        Sinkhole::Responses::AuthIncomplete.expects(:new).with("foo")
        cmd = Sinkhole::Commands::Auth.new(["FOO"], connection)
        cmd.do_process
      end
    end

    context "when checking credentials" do
      it "throws an InvalidAuth error when the credentials are invalid" do
        Sinkhole::Commands::Auth::Foo.expects(:check_credentials).returns(false)
        cmd = Sinkhole::Commands::Auth.new(["FOO", "randomstringhere"], connection)
        expect do
          cmd.do_process
        end.to raise_error(Sinkhole::Errors::InvalidAuth)
      end

      it "goes into an authenticated state when the credentials are valid" do
        state.expects(:<<).with(:auth)
        Sinkhole::Commands::Auth::Foo.expects(:check_credentials).returns(true)
        Sinkhole::Responses::AuthenticationValidated.expects(:new)
        cmd = Sinkhole::Commands::Auth.new(["FOO", "randomstringhere"], connection)
        cmd.do_process
      end
    end
  end
end