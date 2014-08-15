require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/data'

describe Sinkhole::Commands::Data do
  it_ensures_states(:starttls, :auth, :mail, :rcpt)
  it_ensures_no_arguments_present

  let(:state) do
    mock()
  end

  let (:databuffer) do
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
    connection.stubs(:databuffer).returns(databuffer)
  end

  subject do
    Sinkhole::Commands::Data.new([], connection)
  end

  context "when processing" do
    it "returns the from and calls the mail callback" do
      state.expects(:<<).with(:data)
      connection.expects(:reset_databuffer)
      Sinkhole::Responses::StartMailInput.expects(:new).returns("fake")
      expect(subject.do_process).to eq("fake")
    end
  end

  context "when processing a line of data" do
    context "ending on a <CRLF>.<CRLF>" do
      before do
        state.expects(:delete).times(3)
      end

      it "flushes the last bit of data from the databuffer" do
        databuffer.expects(:length).returns(1)
        connection.expects(:callback).times(2).returns(true)
        databuffer.expects(:clear)
        Sinkhole::Responses::ActionCompleted.expects(:new).returns("fake")
        response = Sinkhole::Commands::Data.process(connection, ".")
        expect(response).to eq("fake")
      end

      it "returns an error when the callback returns false" do
        databuffer.expects(:length).returns(0)
        connection.expects(:callback).returns(false)
        databuffer.expects(:clear).times(0)
        Sinkhole::Errors::TransactionFailed.expects(:new).returns("fake")
        response = Sinkhole::Commands::Data.process(connection, ".")
        expect(response).to eq("fake")
      end
    end

    context "inputting any line of text other than ." do
      it "appends the line to the databuffer" do
        databuffer.expects(:<<).with("line")
        databuffer.expects(:length).returns(0)
        response = Sinkhole::Commands::Data.process(connection, "line")
        expect(response).to be_nil
      end

      it "calls the data_chunk callback if the databuffer is full" do
        databuffer.expects(:<<).with("line")
        databuffer.expects(:length).returns(4097)
        connection.expects(:callback)
        databuffer.expects(:clear)
        response = Sinkhole::Commands::Data.process(connection, "line")
        expect(response).to be_nil
      end
    end
  end
end