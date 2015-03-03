require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/ehlo'

describe Sinkhole::Commands::Ehlo do
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
    Sinkhole::Commands::Ehlo.new([], connection)
  end

  before do
    connection.stubs(:state).returns(state)
  end

  it "processes properly" do
    connection.expects(:reset_state)
    state.expects(:<<).with(:ehlo)
    Sinkhole::Responses::ActionCompleted.expects(:new).times(6)
    response = subject.do_process
    expect(response.length).to equal(6)
  end
end