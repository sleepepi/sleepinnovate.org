# frozen_string_literal: true

# Override for devise unlocks controller.
class UnlocksController < Devise::UnlocksController
  layout "full_page"
end
