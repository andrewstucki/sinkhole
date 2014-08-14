require 'spec_helper'
require 'sinkhole/commands/command'
require 'sinkhole/commands/mail'

describe Sinkhole::Commands::Mail do
  it_ensures_states(:starttls, :auth)
  it_ensures_not_states(:mail)
  it_ensures_arguments_present
end