#!/usr/bin/env ruby

$:.unshift File.join(File.expand_path(File.join(__FILE__,'..','..')), 'lib')

require 'bundler/setup'
require 'sinkhole'

class SMTPHandler < Sinkhole::Handler
  callback :auth, :check_auth
  callback :mail, :permission_to_mail_from?
  callback :rcpt, :permission_to_mail_to?
  callback :data_chunk, :stash_chunk
  callback :message, :valid_message?
  callback :rset, :dump_auth
  callback :vrfy, :search_address

  def check_auth(user, pass, id)
    true
  end

  def permission_to_mail_from?(address, id)
    true
  end

  def permission_to_mail_to?(user, id)
    true
  end

  def stash_chunk(chunk, id)
    @logger.debug chunk.join("\n")
  end

  def valid_message?(id)
    true
  end

  def dump_auth(id)
    # puts "dumping auth"
  end

  def search_address(address, id)
    # vrfy returns local-part@domain
    address
  end
end

Sinkhole::Server.start! '127.0.0.1', 5870, SMTPHandler
