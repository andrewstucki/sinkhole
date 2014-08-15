require 'spec_helper'
require 'sinkhole/commands/command'

class FakeCommand < Sinkhole::Commands::Command
  ensure_state :fake_state
  ensure_no_state :no_fake_state, "No fake state for you!"

  attr_accessor :args

  def do_process
    "Fake Result"
  end
end

class FakeCommandNoArgs < FakeCommand
  ensure_no_args
end

class FakeCommandArgs < FakeCommand
  ensure_args "Fake args required!"
end

describe Sinkhole::Commands::Command do
  it "raises a CommandNotImplemented error on do_process" do
    expect do
      cmd = Sinkhole::Commands::Command.new(nil, nil)
      cmd.process
    end.to raise_error(Sinkhole::Errors::CommandNotImplemented)
  end

  context "the syntactic sugar class commands" do
    context "when ensuring a given state" do
      it "raises a BadSequence error when the connection is not in the given state" do
        connection = mock()
        connection.stubs(:state).returns([])
        command = FakeCommand.new([], connection)
        expect do
          command.process
        end.to raise_error(Sinkhole::Errors::BadSequence)
      end

      it "does nothing when the connection is in the state" do
        connection = mock()
        connection.stubs(:state).returns([:fake_state])
        command = FakeCommand.new([], connection)
        expect do
          command.process
        end.not_to raise_error
      end
    end

    context "when ensuring not a given state" do
      it "raises a BadSequence error with a custom message when the connection is in the given state" do
        connection = mock()
        connection.stubs(:state).returns([:fake_state, :no_fake_state])
        command = FakeCommand.new([], connection)
        expect do
          command.process
        end.to raise_error(Sinkhole::Errors::BadSequence)
      end
    end

    context "when ensuring no argument" do
      it "raises a CommandSyntax error when there are arguments passed into the command" do
        connection = mock()
        connection.stubs(:state).returns([:fake_state])
        command = FakeCommandNoArgs.new(["args"], connection)
        expect do
          command.process
        end.to raise_error(Sinkhole::Errors::CommandSyntax)
      end

      it "does nothing when no arguments are present" do
        connection = mock()
        connection.stubs(:state).returns([:fake_state])
        command = FakeCommandNoArgs.new([], connection)
        expect do
          command.process
        end.not_to raise_error
      end
    end

    context "when ensuring arguments" do
      it "raises a CommandSyntax error with a custom message when there are no arguments" do
        connection = mock()
        connection.stubs(:state).returns([:fake_state])
        command = FakeCommandArgs.new([], connection)
        expect do
          command.process
        end.to raise_error(Sinkhole::Errors::CommandSyntax)
      end

      it "does nothing when arguments are present" do
        connection = mock()
        connection.stubs(:state).returns([:fake_state])
        command = FakeCommandArgs.new(["args"], connection)
        expect do
          command.process
        end.not_to raise_error
      end
    end
  end

  it "runs before and after hooks when processing" do
    connection = mock()
    connection.stubs(:state).returns([:fake_state])
    command = FakeCommand.new([], connection)
    command.expects(:run_hook).with(any_of(:before_process, :after_process)).at_least(2)
    expect(command.process).to eq("Fake Result")
  end
end