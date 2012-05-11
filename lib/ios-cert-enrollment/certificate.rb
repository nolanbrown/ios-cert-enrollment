require File.expand_path('../configuration', __FILE__)
require "openssl"

module IOSCertEnrollment
  class Certificate
    
    attr_accessor :certificate, :mime_type
    
    def initialize(certificate,mime_type)
      self.certificate = certificate
      self.mime_type = mime_type
      
    end
    
  end
end