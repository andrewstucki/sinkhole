require 'celluloid/io'
require 'sinkhole/connection'

require 'ext/patches/celluloid_io_ssl_socket'

module Sinkhole

  def self.logger
    Celluloid.logger
  end

  class Server
    include ::Celluloid::IO

    attr_reader :using_ssl

    finalizer :finalize

    def self.start!(host, port, key = nil, cert = nil)
      supervisor = self.supervise(host, port, key, cert)
      trap("INT") { supervisor.terminate; exit }

      loop do
        sleep 5 while supervisor.alive?
      end
    end

    def initialize(host, port, handler, key = nil, cert = nil)
      server = TCPServer.new(host, port)
      server.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      @handler = handler
      @using_ssl = !(key.nil? || cert.nil?)
      if @using_ssl
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.cert = OpenSSL::X509::Certificate.new File.open(cert)
        ctx.key = OpenSSL::PKey::RSA.new File.open(key)
        ctx.ssl_version = :SSLv23
        @server = SSLServer.new(server, ctx)
        @server.start_immediately = false
      else
        @server = server
      end
      async.run
    end

    def finalize
      @server.close if @server
    end

    def run
      loop { async.handle_connection @server.accept }
    end

    def handle_connection(socket)
      connection = Connection.new(socket, @handler.new, self)
    rescue EOFError
      socket.close
    end
  end
end