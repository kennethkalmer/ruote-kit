
unless :foo.respond_to?(:<=>)

  class Symbol

    # Compares self against other
    # using the corresponding #to_s versions
    # of self and other.
    #
    # Returns the Integer result of the comparison.
    def <=>(other)
      to_s <=> other.to_s
    end
  end
end
