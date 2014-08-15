require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/vrfy'

describe Sinkhole::Commands::Vrfy do
  it_ensures_states(:starttls, :auth)
  it_ensures_arguments_present

  let(:connection) do
    connection = mock()
    connection.stubs(:domain).returns("Fake")
    connection.stubs(:peer).returns("127.0.0.1")
    connection
  end

  subject do
    Sinkhole::Commands::Vrfy.new(["user"], connection)
  end

  it "responds with the user when the verified user is not nil" do
    connection.expects(:callback).with(:vrfy, "user").returns("user")
    Sinkhole::Responses::ActionCompleted.expects(:new).with("user").returns("fake")
    expect(subject.do_process).to eq("fake")
  end

  it "raises a MailboxNameNotAllowed error when the callback returns a falsy statement" do
    connection.expects(:callback).returns(nil)
    expect do
      subject.do_process
    end.to raise_error(Sinkhole::Errors::MailboxNameNotAllowed)
  end
end