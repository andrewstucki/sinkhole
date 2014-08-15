require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/mail'

describe Sinkhole::Commands::Mail do
  it_ensures_states(:starttls, :auth)
  it_ensures_not_states(:mail)
  it_ensures_arguments_present

  let(:state) do
    mock()
  end

  let(:connection) do
    connection = mock()
    connection.stubs(:domain).returns("Fake")
    connection.stubs(:peer).returns("127.0.0.1")
    connection
  end

  before do
    connection.stubs(:state).returns(state)
  end

  context "processing command arguments" do
    context "when both size and from are valid" do
      subject do
        Sinkhole::Commands::Mail.new(["FROM:<a>", "SIZE=1"], connection)
      end

      it "returns the from and calls the mail callback" do
        connection.expects(:callback).returns(true)
        state.expects(:<<).with(:mail)
        Sinkhole::Responses::ActionCompleted.expects(:new).returns("fake")
        expect(subject.do_process).to eq("fake")
      end

      it "raises a MailboxUnavailable error when the callback returns false" do
        connection.expects(:callback).returns(false)
        expect do
          subject.do_process
        end.to raise_error(Sinkhole::Errors::MailboxUnavailable)
      end
    end

    context "when size is invalid" do
      subject do
        Sinkhole::Commands::Mail.new(["FROM:<a>", "SIZE=99999999999999"], connection)
      end

      it "raises an ExceededStorageAllocation error" do
        expect do
          subject.do_process
        end.to raise_error(Sinkhole::Errors::ExceededStorageAllocation)
      end
    end

    context "when from is invalid" do
      subject do
        Sinkhole::Commands::Mail.new(["FROM:a", "SIZE=1"], connection)
      end

      it "raises a CommandSyntax error" do
        expect do
          subject.do_process
        end.to raise_error(Sinkhole::Errors::CommandSyntax)
      end
    end

    context "when attributes are invalid" do
      subject do
        Sinkhole::Commands::Mail.new(["FRO", "SIZ"], connection)
      end

      it "raises a CommandSyntax error" do
        expect do
          subject.do_process
        end.to raise_error(Sinkhole::Errors::CommandSyntax)
      end
    end
  end
end