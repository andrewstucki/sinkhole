require 'sinkhole/responses'
require 'sinkhole/errors'
require 'sinkhole/commands'

require 'socket'
require 'securerandom'

module Sinkhole
  class Connection

    class SocketClosed < Exception; end

    attr_accessor :state, :databuffer, :username
    attr_reader :peer, :domain, :linebuffer, :server

    def initialize(socket, server)
      @id = ::SecureRandom.hex(8)
      @socket = socket
      @server = server
      @domain = Socket.gethostname
      _, _, @peer = @socket.peeraddr

      @delimiter = "\n"
      @linebuffer = []
      @username = nil

      reset_state

      send_response Responses::ServiceReady.new("#{@domain} ESMTP")

      begin
        while data = readpartial(4096) do
          receive_data data
        end
      rescue SocketClosed
        @server.logger.debug "Connection closed"
      end
    end

    def callback(name, *args)
      if @server.callbacks[name]
        args << @id
        @server.send(@server.callbacks[name], *args)
      else
        nil
      end
    end

    def reset_state
      @state ||= []
      s, @state = @state, []
      @state << :starttls if s.include?(:starttls)
      @state << :ehlo if s.include?(:ehlo)
    end

    def reset_databuffer
      @databuffer = []
    end

    def receive_data(data)
      return unless (data and data.length > 0)

      if delimiter_index = data.index(@delimiter)
        @linebuffer << data[0...delimiter_index]
        line = @linebuffer.join
        @linebuffer.clear
        line.chomp!
        receive_line line
        receive_data data[(delimiter_index + @delimiter.length)..-1]
      else
        @linebuffer << data
      end
    end

    def receive_line(line)
      return if line.empty? unless @state.include?(:data)
      if @state.include?(:data)
        response = Commands::Data.process(self, line)
        return if response.nil?
      elsif @state.include?(:auth_login)
        response = Commands::Auth::Login.process(self, line)
      elsif @state.include?(:auth_plain)
        response = Commands::Auth::Plain.process(self, line)
      else
        command, *args = line.split
        return if command.nil?
        begin
          if !@server.using_ssl && command.downcase == "starttls"
            response = Errors::CommandNotImplemented.new("starttls", "Not implemented")
          else
            cmd_klass = Commands.const_get(command.downcase.capitalize)
            cmd = cmd_klass.new(args, self)
            response = cmd.process
          end
        rescue NameError => e
          response = Errors::CommandNotRecognized.new(command, "Unrecognized command")
        rescue Errors::SmtpError => e
          response = e
        end
      end
      send_response response
      perform_response_action response.action if response.respond_to?(:action) and response.action
    end

    def send_response(response)
      if response.kind_of?(Array)
        response.each{|r| send_response(r)}
        return
      end
      # @server.logger.info response.debug
      write response.render
    end

    def perform_response_action(action)
      case action
      when :quit
        close
      when :reset
        callback :rset
      when :starttls
        start_tls
      end
    end

    private

    def write(data)
      @socket.write data
    end

    def readpartial(size)
      @socket.readpartial size
    end

    def close
      @socket.close
      raise SocketClosed
    end

    def start_tls
      @socket.accept
    end
  end
end