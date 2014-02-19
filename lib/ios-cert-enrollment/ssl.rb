module IOSCertEnrollment
  module SSL
    @@key, @@certificate, @@intermediate_certificates = nil
    class << self    
      def key
        return @@key if @@key
        return @@key = OpenSSL::PKey::RSA.new(File.read(IOSCertEnrollment.ssl_key_path))
      end
    
      def certificate
        return @@certificate if @@certificate
        return @@certificate = OpenSSL::X509::Certificate.new(File.read(IOSCertEnrollment.ssl_certificate_path))
      end

      def intermediate_certificates
        return @@intermediate_certificates if @@intermediate_certificates
        certificate_paths = IOSCertEnrollment.intermediate_certificate_paths || []
        @@intermediate_certificates = certificate_paths.collect{|x| OpenSSL::X509::Certificate.new(File.read(x))}
      end
    end
    
  end  
end