# frozen_string_literal: true

module SleepInnovate
  module VERSION #:nodoc:
    MAJOR = 1
    MINOR = 1
    TINY = 0
    BUILD = "pre" # "pre", "beta1", "beta2", "rc", "rc2", nil

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join(".")
  end
end
