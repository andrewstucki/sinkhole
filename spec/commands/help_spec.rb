require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/help'

describe Sinkhole::Commands::Help do
  let(:connection) do
    connection = mock()
    connection.stubs(:domain).returns("Fake")
    connection.stubs(:peer).returns("127.0.0.1")
    connection
  end

  subject do
    Sinkhole::Commands::Help.new([], connection)
  end

  it "processes properly" do
    Sinkhole::Responses::HelpMessage.expects(:new)
    response = subject.do_process
  end
end