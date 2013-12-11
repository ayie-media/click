require 'click/indeterminable'

module Click
  class Clicker
    attr_reader :session_name

    def initialize(session_name)
      @session_name = session_name
    end

    # Update internal state to reflect the current global state.
    def click!
      observers.each { |o| o.before_click(self) }

      ObjectSpace.garbage_collect

      @state = Hash.new(0)
      ObjectSpace.each_object do |object|
        begin
          klass = object.class
          klass = Click::Indeterminable unless klass.is_a?(Class)
        rescue NoMethodError
          klass = Click::Indeterminable
        end

        @state[klass] += 1
      end

      @state[Symbol] = Symbol.all_symbols.count

      observers.each { |o| o.after_click(self) }
    end

    # @return [Hash] A hash of Class => count (number of instances of that class)
    # @note Must be called after calling #click!
    def object_counts
      @state.dup
    end

    # @return [Integer] How many instances there are of the given class
    # @note Must be called after calling #click!
    def instance_count(klass)
      @state.fetch(klass, 0)
    end

    # Add an observer to this Clicker.
    # @see Click::Observer
    def add_observer(observer)
      observers << observer
      observer.on_add(self)
    end

    private
    def observers
      @observers ||= []
    end
  end

  class << self
    # Yields a Click::Clicker with an associated Click::Database::Writer connected to the given connection_string.
    # @param session_name [String] What to use for the name of this session in the database.
    # @param connection_string [String] Sequel connection string to use for connecting to a database.
    def clicker_with_database(session_name, connection_string)
      require 'click/database'
      Click::Database.with_database(connection_string) do
        require 'click/database/writer'
        writer = Click::Database::Writer.new
        clicker = Click::Clicker.new(session_name)
        clicker.add_observer(writer)
        yield clicker
      end
    end
  end
end
