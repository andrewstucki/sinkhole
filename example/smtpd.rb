#!/usr/bin/env ruby

require_relative '../lib/sinkhole'

class Server < Sinkhole::Server
  callback :auth, :check_auth
  callback :mail, :permission_to_mail_from?
  callback :rcpt, :permission_to_mail_to?
  callback :data_chunk, :stash_chunk
  callback :message, :valid_message?
  callback :rset, :dump_auth
  callback :vrfy, :search_address

  def check_auth(user, pass)
    true
  end

  def permission_to_mail_from?(address)
    true
  end

  def permission_to_mail_to?(user)
    true
  end

  def stash_chunk(chunk)
    @logger.debug chunk.join("\n")
  end

  def valid_message?
    true
  end

  def dump_auth
    # puts "dumping auth"
  end

  def search_address(address)
    # vrfy returns local-part@domain
    address
  end
end

keyfile = File.join(File.expand_path('../..', __FILE__), "server.key")
certfile = File.join(File.expand_path('../..', __FILE__), "server.crt")

Server.start! '0.0.0.0', 587, keyfile, certfile
