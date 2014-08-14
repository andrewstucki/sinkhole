require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/vrfy'

describe Sinkhole::Commands::Vrfy do
  it_ensures_states(:starttls, :auth)
  it_ensures_arguments_present
end