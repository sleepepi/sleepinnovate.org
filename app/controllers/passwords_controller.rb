# frozen_string_literal: true

# Override for devise passwords controller.
class PasswordsController < Devise::PasswordsController
  layout "full_page"
end
