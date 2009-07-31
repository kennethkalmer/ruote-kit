module RuoteKit
  # Rack::Builder wrapped for our own use
  class Racker

    attr_reader :builder

    class << self
      private :new

      def to_app
        @racker ||= new
        @racker.builder
      end

    end

    def initialize
      @builder = Rack::Builder.new do
        use Rack::CommonLogger
      end
    end
  end
end
