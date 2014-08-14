require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/starttls'

describe Sinkhole::Commands::Starttls do
  it_ensures_states(:ehlo)
  it_ensures_not_states(:starttls)
  it_ensures_no_arguments_present

  let(:state) do
    mock()
  end

  let(:connection) do
    connection = mock()
    connection.stubs(:domain).returns("Fake")
    connection.stubs(:peer).returns("127.0.0.1")
    connection
  end

  subject do
    Sinkhole::Commands::Starttls.new([], connection)
  end

  before do
    connection.stubs(:state).returns(state)
  end

  it "processes properly" do
    state.expects(:<<).with(:starttls)
    Sinkhole::Responses::ServiceReady.expects(:new)
    response = subject.do_process
  end
end