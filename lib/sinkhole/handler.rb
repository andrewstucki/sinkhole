module Sinkhole
  class Handler
    VALID_CALLBACKS = [ :auth, :mail, :rcpt, :data_chunk, :vrfy, :message, :rset ]

    @@callbacks = {}

    def self.callback(name, sym)
      @@callbacks[name] = sym
    end

    def callbacks
      @@callbacks
    end
  end
end