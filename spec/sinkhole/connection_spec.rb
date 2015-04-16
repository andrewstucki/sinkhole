require 'spec_helper'
require 'sinkhole/connection'

describe Sinkhole::Connection do
  let(:socket) do
    socket = mock()
    socket.expects(:peeraddr).returns([nil, nil, '127.0.0.1'])
    socket.expects(:write)
    socket.expects(:readpartial)
    socket
  end

  let(:server) do
    server = mock()
    server.stubs(:using_ssl).returns(true)
    server
  end

  let(:handler) do
    handler = mock()
    handler.stubs(:callbacks).returns({random: :random_callback})
    handler
  end

  subject { Sinkhole::Connection.new(socket, handler, server)}

  it "closes the socket when executing close" do
    socket.expects(:close)
    expect { subject.perform_response_action(:quit) }.to raise_exception Sinkhole::Connection::SocketClosed
  end

  it "starts tls when requested to do so" do
    socket.expects(:accept)
    subject.perform_response_action(:starttls)
  end

  it "resets the databuffer" do
    subject.reset_databuffer
    expect(subject.databuffer).to eq([])
  end

  context "initialization" do
    it "gets the connected client's address" do
      expect(subject.peer).to eq('127.0.0.1')
    end

    it "initializes the state buffer" do
      expect(subject.state).to eq([])
    end
  end

  context "calling a server callback" do
    it "calls the callback if it exists" do
      handler.expects(:random_callback).with("here", "are", "some", "args").returns(true)
      expect(subject.callback(:random, "here", "are", "some", "args")).to equal(true)
    end

    it "returns nil if the callback doesn't exist" do
      server.expects(:send).times(0)
      expect(subject.callback(:nonexistant)).to be_nil
    end
  end

  context "resetting the state buffer" do
    it "keeps starttls and ehlo if they are already in the state buffer" do
      subject.state = [:ehlo, :starttls, :other, :more]
      subject.reset_state
      expect(subject.state).to contain_exactly(:ehlo, :starttls)
    end

    it "does not add any state to the buffer" do
      subject.reset_state
      expect(subject.state).to eq([])
    end
  end

  context "receiving data" do
    it "doesn't process lines when no data is passed in" do
      subject.receive_data(nil)
      subject.expects(:receive_line).times(0)
      expect(subject.linebuffer).to eq([])
    end

    it "processes lines inidividually" do
      subject.expects(:receive_line).with("test").times(3)
      subject.receive_data("test\ntest\ntest\n")
    end

    it "appends unfinished lines to the line buffer" do
      subject.receive_data("test")
      expect(subject.linebuffer).to eq(["test"])
    end
  end

  context "processing a line of data" do
    it "discards the line if not in the data state" do
      line = ""
      line.expects(:split).times(0)
      subject.expects(:send_response).times(0)
      subject.receive_line(line)
    end

    it "asks the data command to process the line if in the data state" do
      response = mock()
      response.expects(:action).times(2).returns("action")
      Sinkhole::Commands::Data.expects(:process).returns(response)
      subject.state = [:data]
      subject.expects(:send_response).with(response)
      subject.expects(:perform_response_action).with("action")
      subject.receive_line("test")
    end

    it "asks the auth login command to process the line if in the auth_login state" do
      response = mock()
      response.expects(:action).times(2).returns("action")
      Sinkhole::Commands::Auth::Login.expects(:process).returns(response)
      subject.state = [:auth_login]
      subject.expects(:send_response).with(response)
      subject.expects(:perform_response_action).with("action")
      subject.receive_line("test")
    end

    it "asks the auth plain command to process the line if in the auth_plain state" do
      response = mock()
      response.expects(:action).times(2).returns("action")
      Sinkhole::Commands::Auth::Plain.expects(:process).returns(response)
      subject.state = [:auth_plain]
      subject.expects(:send_response).with(response)
      subject.expects(:perform_response_action).with("action")
      subject.receive_line("test")
    end

    context "when attempting to dynamically find the user's command" do
      let(:command) do
        mock()
      end

      let(:response) do
        response = mock()
        response.stubs(:action).returns("action")
        response
      end

      before do
        Sinkhole::Commands.expects(:const_get).with("Fake").returns(Sinkhole::Commands::Command)
        Sinkhole::Commands::Command.expects(:new).returns(command)
      end

      it "tries to get the command and execute process on it" do
        command.expects(:process).returns(response)

        subject.expects(:send_response).with(response)
        subject.expects(:perform_response_action).with("action")
        subject.receive_line("fake test")
      end

      it "responds with a CommandNotRecognized error when it can't find the command" do
        command.expects(:process).raises(NameError)
        Sinkhole::Errors::CommandNotRecognized.expects(:new).returns(response)

        subject.expects(:send_response).with(response)
        subject.expects(:perform_response_action).with("action")
        subject.receive_line("fake test")
      end

      it "responds with any SmtpErrors thrown from processing" do
        response = Sinkhole::Errors::SmtpError.new(nil, "action")
        command.expects(:process).raises(response)
        subject.expects(:send_response).with(response)
        subject.receive_line("fake test")
      end
    end
  end

  context "sending a response" do
    it "handles all responses in an array" do
      response = mock()
      response.expects(:render).times(3).returns("rendered")
      subject.expects(:write).times(3).with("rendered")
      subject.send_response([response, response, response])
    end

    it "handles single object responses" do
      response = mock()
      response.expects(:render).returns("rendered")
      subject.expects(:write).with("rendered")
      subject.send_response(response)
    end
  end

  context "peforming a response action" do
    it "handles the quit action" do
      subject.expects(:close)
      subject.perform_response_action(:quit)
    end

    it "handles the reset action" do
      subject.expects(:callback).with(:rset)
      subject.perform_response_action(:reset)
    end

    it "handles the starttls action" do
      subject.expects(:start_tls)
      subject.perform_response_action(:starttls)
    end
  end
end