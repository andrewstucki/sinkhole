require 'hooks'

module Sinkhole
  module Commands
    class Command
      include Hooks

      define_hooks :after_process, :before_process

      def initialize(args, connection)
        @args = args
        @connection = connection
      end

      def process
        self.run_hook :before_process
        result = do_process
        self.run_hook :after_process
        result
      end

      private

      def do_process
        raise Errors::CommandNotImplemented.new(self, "Unimplemented command")
      end

      def ensure_args(msg)
        raise Errors::CommandSyntax.new(self, msg) if @args.empty?
      end

      def ensure_no_args
        raise Errors::CommandSyntax.new(self, "#{self.class.name.split('::').last.upcase} requires no arguments") unless @args.empty?
      end

      def ensure_state(state)
        action = state.to_s.upcase
        action = "HELO/EHLO" if action == "HELO" || action == "EHLO"
        raise Errors::BadSequence.new(self, "Must #{action} first") unless @connection.state.include?(state)
      end

      def ensure_no_state(state, msg)
        raise Errors::BadSequence.new(self, msg) if @connection.state.include?(state)
      end

      def self.ensure_no_args
        self.before_process :ensure_no_args
      end

      def self.ensure_args(msg)
        method_name = "ensure_#{self.class.name.split('::').last.downcase}_args"
        self.before_process method_name.to_sym
        define_method method_name do
          ensure_args(msg)
        end
      end

      def self.ensure_no_state(state, msg)
        method_name = "ensure_no_state_#{state}"
        self.before_process method_name.to_sym
        define_method method_name do
          ensure_no_state(state, msg)
        end
      end

      def self.ensure_state(state)
        method_name = "ensure_state_#{state}"
        self.before_process method_name.to_sym
        define_method method_name do
          ensure_state(state)
        end
      end

    end
  end
end