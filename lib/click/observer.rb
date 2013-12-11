module Click
  module Observer
    # Called with the associated clicker before any actions taken by Click::Clicker#click!
    # @param clicker [Click::Clicker] The clicker being observed
    def before_click(clicker)
    end

    # Called with the associated clicker after any actions taken by Click::Clicker#click!
    # @param clicker [Click::Clicker] The clicker being observed
    def after_click(clicker)
    end

    # Called with the associated clicker when calling Click::Clicker#add_observer
    # @param clicker [Click::Clicker] The clicker being observed
    def on_add(clicker)
    end
  end
end
