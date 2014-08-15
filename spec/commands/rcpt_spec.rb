require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/rcpt'

describe Sinkhole::Commands::Rcpt do
  it_ensures_states(:starttls, :auth, :mail)
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
    context "when to is valid" do
      subject do
        Sinkhole::Commands::Rcpt.new(["TO:<a>"], connection)
      end

      it "returns the to and calls the mail callback" do
        connection.expects(:callback).returns(true)
        state.expects(:include?).returns(false)
        state.expects(:<<).with(:rcpt)
        Sinkhole::Responses::ActionCompleted.expects(:new).returns("fake")
        expect(subject.do_process).to eq("fake")
      end

      it "doesn't change the state if already in rcpt state" do
        connection.expects(:callback).returns(true)
        state.expects(:include?).returns(true)
        state.expects(:<<).with(:rcpt).times(0)
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

    context "when to is invalid" do
      subject do
        Sinkhole::Commands::Rcpt.new(["TO:a"], connection)
      end

      it "raises a CommandSyntax error" do
        expect do
          subject.do_process
        end.to raise_error(Sinkhole::Errors::CommandSyntax)
      end
    end

    context "when attributes are invalid" do
      subject do
        Sinkhole::Commands::Rcpt.new(["T"], connection)
      end

      it "raises a CommandSyntax error" do
        expect do
          subject.do_process
        end.to raise_error(Sinkhole::Errors::CommandSyntax)
      end
    end

  end
end