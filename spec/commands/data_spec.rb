require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/data'

describe Sinkhole::Commands::Data do
  it_ensures_states(:starttls, :auth, :mail, :rcpt)
  it_ensures_no_arguments_present
end