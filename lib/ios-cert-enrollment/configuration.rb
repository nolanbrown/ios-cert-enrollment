require File.expand_path('../version', __FILE__)

module IOSCertEnrollment
  # Defines constants and methods related to configuration
  module Configuration
    VALID_OPTIONS_KEYS = [
      :ssl_certificate_path,
      :ssl_key_path,
      :base_url,
      :identifier,
      :display_name,
      :organization
    ].freeze

    attr_accessor *VALID_OPTIONS_KEYS
    
    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end

    # Create a hash of options and their values
    def options
      VALID_OPTIONS_KEYS.inject({}) do |option, key|
        option.merge!(key => send(key))
      end
    end
  end
end