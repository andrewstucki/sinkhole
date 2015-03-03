def it_ensures_states(*states)
  it "should not error when all the states are present" do
    connection = mock()
    connection.stubs(:state).returns(states)
    expect do
      begin
        obj = described_class.new([], connection)
        obj.stubs(:do_process)
        obj.process
      rescue Sinkhole::Errors::CommandSyntax
        obj = described_class.new(["not blank"], connection)
        obj.stubs(:do_process)
        obj.process
      end
    end.not_to raise_error
  end

  states.each do |state|
    it "should error when #{state} is not present" do
      connection = mock()
      connection.stubs(:state).returns(states.reject {|s| s==state})
      expect do
        begin
          obj = described_class.new([], connection)
          obj.stubs(:do_process)
          obj.process
        rescue Sinkhole::Errors::CommandSyntax
          obj = described_class.new(["not blank"], connection)
          obj.stubs(:do_process)
          obj.process
        end
      end.to raise_error(Sinkhole::Errors::BadSequence)
    end
  end
end

def it_ensures_not_states(*states)
  states.each do |state|
    it "should error when #{state} is present" do
      connection = mock()
      connection.stubs(:state).returns([state])
      expect do
        begin
          obj = described_class.new([], connection)
          obj.stubs(:do_process)
          obj.process
        rescue Sinkhole::Errors::CommandSyntax
          obj = described_class.new(["not blank"], connection)
          obj.stubs(:do_process)
          obj.process
        end
      end.to raise_error(Sinkhole::Errors::BadSequence)
    end
  end
end

def it_ensures_arguments_present
  it "should error when no arguments are present" do
    connection = mock()
    expect do
      obj = described_class.new([], connection)
      obj.stubs(:ensure_no_state)
      obj.stubs(:ensure_state)
      obj.stubs(:do_process)
      obj.process
    end.to raise_error(Sinkhole::Errors::CommandSyntax)
  end

  it "should not error when arguments are present" do
    connection = mock()
    expect do
      begin
        obj = described_class.new(["args"], connection)
        obj.stubs(:ensure_no_state)
        obj.stubs(:ensure_state)
        obj.stubs(:do_process)
        obj.process
      rescue Sinkhole::Errors::CommandParameterNotImplemented
      end
    end.not_to raise_error
  end
end

def it_ensures_no_arguments_present
  it "should not error when no arguments are present" do
    connection = mock()
    expect do
      obj = described_class.new([], connection)
      obj.stubs(:ensure_no_state)
      obj.stubs(:ensure_state)
      obj.stubs(:do_process)
      obj.process
    end.not_to raise_error
  end

  it "should error when arguments are present" do
    connection = mock()
    expect do
      obj = described_class.new(["args"], connection)
      obj.stubs(:ensure_no_state)
      obj.stubs(:ensure_state)
      obj.stubs(:do_process)
      obj.process
    end.to raise_error(Sinkhole::Errors::CommandSyntax)
  end
end