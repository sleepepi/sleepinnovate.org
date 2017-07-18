# frozen_string_literal: true

# Establishes connection with Slice JSON API.
class SliceRecord
  def project_url
    "#{ENV['slice_url']}/api/v1/projects/#{ENV['project_id']}-#{ENV['project_auth_token']}"
  end
end
