require 'celluloid/io'
require 'socket'

# This really shouldn't be in Celluloid, as this seems to be an issue when you haven't
# actually done the tls handshake in the SSLSocket class in the openssl library
# the idea is that when you haven't done tls any call to close on the SSLSocket returns
# nil under mri or an EOFError on jruby because it's ssl "engine" hasn't been instantiated yet, this keeps the
# underlying socket file descriptor from being told to shutdown, we want to make sure
# that the socket closes even when the tls handshake hasn't been done yet
module Celluloid
  module IO
    class SSLSocket
      def close_with_patch
        #for mri
        @socket.io.shutdown if close_without_patch.nil? && !@socket.io.closed?
      rescue EOFError
        #for jruby
        @socket.io.shutdown unless @socket.io.closed?
      rescue Errno::ENOTCONN
        #for mri
      end

      alias_method :close_without_patch, :close
      alias_method :close, :close_with_patch
    end
  end
end