require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/auth/login'

require 'base64'

describe Sinkhole::Commands::Auth::Login do

  let(:username) do
    Base64.encode64("Username:").chomp
  end

  let(:password) do
    Base64.encode64("Password:").chomp
  end

  it "returns :auth_login as its state" do
    expect(Sinkhole::Commands::Auth::Login.state).to eq(:auth_login)
  end

  it "returns base64 encoded 'Username:' when first prompting" do
    expect(Sinkhole::Commands::Auth::Login.prompt).to eq(username)
  end

  it "converts credentials from base64 and passes them into a callback" do
    user = Base64.encode64("Fake").chomp
    pass = Base64.encode64("Test").chomp
    connection = mock()
    connection.expects(:callback).with(:auth, "Fake", "Test")
    Sinkhole::Commands::Auth::Login.check_credentials(connection, [user, pass])
  end

  it "raises an InvalidAuth error when there are too many things passed into creds" do
    user = Base64.encode64("Fake").chomp
    pass = Base64.encode64("Test").chomp
    expect do
      Sinkhole::Commands::Auth::Login.check_credentials(nil, [user, pass, "bar"])
    end.to raise_error(Sinkhole::Errors::InvalidAuth)
  end

  it "prompts for a password after the user has put in the username" do
    blah = Base64.encode64("blah")
    connection = mock()
    connection.expects(:username).returns(nil)
    connection.expects(:username=).with("blah")
    Sinkhole::Responses::AuthIncomplete.expects(:new).with(password)
    Sinkhole::Commands::Auth::Login.process(connection, blah)
  end

  it "returns an InvalidAuth error when the user is inputting a password and a callback returns false" do
    pass = Base64.encode64("pass")
    connection = mock()
    state = mock()
    state.expects(:delete).with(:auth_login)
    connection.expects(:username).times(2).returns("blah")
    connection.expects(:username=)
    connection.expects(:state).returns(state)
    connection.expects(:callback).returns(false)

    Sinkhole::Errors::InvalidAuth.expects(:new)
    Sinkhole::Commands::Auth::Login.process(connection, pass)
  end

  it "returns an an AuthenticationValidated response when the user is inputting a password and a callback returns true" do
    pass = Base64.encode64("pass")
    connection = mock()
    state = mock()
    state.expects(:delete).with(:auth_login)
    state.expects(:<<).with(:auth)
    connection.expects(:username).times(2).returns("blah")
    connection.expects(:username=)
    connection.expects(:state).times(2).returns(state)
    connection.expects(:callback).returns(true)

    Sinkhole::Responses::AuthenticationValidated.expects(:new)
    Sinkhole::Commands::Auth::Login.process(connection, pass)
  end
end