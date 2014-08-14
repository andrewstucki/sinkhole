require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/rcpt'

describe Sinkhole::Commands::Rcpt do
  it_ensures_states(:starttls, :auth, :mail)
  it_ensures_arguments_present
end