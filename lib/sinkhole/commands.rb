module Sinkhole
  module Commands
    require 'sinkhole/commands/command'

    require 'sinkhole/commands/auth'
    require 'sinkhole/commands/data'
    require 'sinkhole/commands/ehlo'
    require 'sinkhole/commands/expn'
    require 'sinkhole/commands/helo'
    require 'sinkhole/commands/help'
    require 'sinkhole/commands/mail'
    require 'sinkhole/commands/noop'
    require 'sinkhole/commands/quit'
    require 'sinkhole/commands/rcpt'
    require 'sinkhole/commands/rset'
    require 'sinkhole/commands/starttls'
    require 'sinkhole/commands/vrfy'
  end
end