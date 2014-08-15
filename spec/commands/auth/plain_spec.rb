require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/auth/plain'

require 'base64'

describe Sinkhole::Commands::Auth::Plain do
  it "returns :auth_plain as its state" do
    expect(Sinkhole::Commands::Auth::Plain.state).to eq(:auth_plain)
  end

  it "returns nil when first prompting" do
    expect(Sinkhole::Commands::Auth::Plain.prompt).to be_nil
  end

  it "converts credentials and passes them into a callback" do
    creds = ["a","Fake", "Test"].join("\000")
    enc_creds = Base64.encode64(creds)
    connection = mock()
    connection.expects(:callback).with(:auth, "Fake", "Test").returns(true)
    Sinkhole::Commands::Auth::Plain.check_credentials(connection, [enc_creds])
  end

  it "raises an InvalidAuth error if there are too many creds" do
    expect do
      Sinkhole::Commands::Auth::Plain.check_credentials(nil, ["1","2"])
    end.to raise_error(Sinkhole::Errors::InvalidAuth)
  end

  context "processing lines of credentials" do
    it "returns an InvalidAuth error if the callback returns false" do
      creds = ["a","Fake", "Test"].join("\000")
      enc_creds = Base64.encode64(creds)
      connection = mock()
      state = mock()
      state.expects(:delete).with(:auth_plain)
      connection.expects(:callback).with(:auth, "Fake", "Test").returns(false)
      connection.expects(:state).returns(state)
      Sinkhole::Errors::InvalidAuth.expects(:new).returns("fake")
      response = Sinkhole::Commands::Auth::Plain.process(connection, enc_creds)
      expect(response).to eq("fake")
    end

    it "returns an AuthenticationValidated response if the callback returns true" do
      creds = ["a","Fake", "Test"].join("\000")
      enc_creds = Base64.encode64(creds)
      connection = mock()
      state = mock()
      state.expects(:delete).with(:auth_plain)
      state.expects(:<<).with(:auth)
      connection.expects(:callback).with(:auth, "Fake", "Test").returns(true)
      connection.expects(:state).times(2).returns(state)
      Sinkhole::Responses::AuthenticationValidated.expects(:new).returns("fake")
      response = Sinkhole::Commands::Auth::Plain.process(connection, enc_creds)
      expect(response).to eq("fake")
    end
  end
end