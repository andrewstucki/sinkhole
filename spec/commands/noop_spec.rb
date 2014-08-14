require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/noop'

describe Sinkhole::Commands::Noop do
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
    Sinkhole::Commands::Noop.new([], connection)
  end

  before do
    connection.stubs(:state).returns(state)
  end

  it "processes properly" do
    Sinkhole::Responses::ActionCompleted.expects(:new).returns("fake")
    response = subject.do_process
    expect(response).to eq("fake")
  end
end