require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/quit'

describe Sinkhole::Commands::Quit do
  it_ensures_no_arguments_present

  let(:connection) do
    connection = mock()
    connection.stubs(:domain).returns("Fake")
    connection.stubs(:peer).returns("127.0.0.1")
    connection
  end

  subject do
    Sinkhole::Commands::Quit.new([], connection)
  end

  it "processes properly" do
    Sinkhole::Responses::ServiceClosingChannel.expects(:new)
    response = subject.do_process
  end
end