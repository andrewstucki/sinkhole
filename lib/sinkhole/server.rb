require 'celluloid/io'
require 'sinkhole/connection'

module Sinkhole
  class Server
    include ::Celluloid::IO

    attr_reader :logger, :using_ssl

    VALID_CALLBACKS = [ :auth, :mail, :rcpt, :data_chunk, :vrfy, :message, :rset ]

    finalizer :finalize

    @@callbacks = {}

    def self.start!(host, port, key = nil, cert = nil)
      supervisor = self.supervise(host, port, key, cert)
      trap("INT") { supervisor.terminate; exit }

      loop do
        sleep 5 while supervisor.alive?
      end
    end

    def self.callback(name, sym)
      @@callbacks[name] = sym
    end

    def callbacks
      @@callbacks
    end

    def initialize(host, port, key = nil, cert = nil)
      server = TCPServer.new(host, port)
      server.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      @using_ssl = !(key.nil? || cert.nil?)
      if @using_ssl
        require 'ext/patches/celluloid_io_ssl_socket'
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.cert = OpenSSL::X509::Certificate.new File.open(cert)
        ctx.key = OpenSSL::PKey::RSA.new File.open(key)
        ctx.ssl_version = :SSLv23
        @server = SSLServer.new(server, ctx)
        @server.start_immediately = false
      else
        @server = server
      end
      @logger = Celluloid.logger
      async.run
    end

    def finalize
      @server.close if @server
    end

    def run
      loop { async.handle_connection @server.accept }
    end

    def handle_connection(socket)
      connection = Connection.new(socket, self)
    rescue EOFError
      socket.close
    end
  end
end