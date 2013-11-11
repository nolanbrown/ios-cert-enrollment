require File.expand_path('../configuration', __FILE__)
require File.expand_path('../certificate', __FILE__)
require File.expand_path('../ssl', __FILE__)

require "openssl"

module IOSCertEnrollment  
  module Sign 
       
    class << self    
      def registration_authority    
        return Certificate.new(SSL.certificate.to_der, "application/x-x509-ca-cert")
      end
      
      def certificate_authority_caps
        return "POSTPKIOperation\nSHA-1\nDES3\n"
      end
    
      def sign_PKI(data)
        
        p7sign = OpenSSL::PKCS7.new(data)
        store = OpenSSL::X509::Store.new
        p7sign.verify(nil, store, nil, OpenSSL::PKCS7::NOVERIFY)
        signers = p7sign.signers
        p7enc = OpenSSL::PKCS7.new(p7sign.data)
        
        # Certificate Signing Request
        csr = p7enc.decrypt(SSL.key, SSL.certificate)
        
        # Signed Certificate
        cert = self.sign_certificate(csr)
        
        degenerate_pkcs7 = OpenSSL::PKCS7.new()
        degenerate_pkcs7.type="signed"
        degenerate_pkcs7.certificates=[cert]
        enc_cert = OpenSSL::PKCS7.encrypt(p7sign.certificates, degenerate_pkcs7.to_der, 
            OpenSSL::Cipher::Cipher::new("des-ede3-cbc"), OpenSSL::PKCS7::BINARY)
        reply = OpenSSL::PKCS7.sign(SSL.certificate, SSL.key, enc_cert.to_der, [], OpenSSL::PKCS7::BINARY)

        return Certificate.new(reply.to_der, "application/x-pki-message")        
      end
      
      def verify_response(raw_postback_data)
        p7sign = OpenSSL::PKCS7.new(raw_postback_data)
        store = OpenSSL::X509::Store.new
        p7sign.verify(nil, store, nil, OpenSSL::PKCS7::NOVERIFY)
        return p7sign           
      end
      def verify_signer(p7sign)
        signers = p7sign.signers
        
        return (signers[0].issuer.to_s == SSL.certificate.subject.to_s)
      end
    
    
    end
    private
    def self.sign_certificate(signing_request)
      request = OpenSSL::X509::Request.new(signing_request)
      
      # New Certificate
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      
      unix_serial = Time.now.to_f.round(2).to_s.gsub(".","")
      (unix_serial.length - 12).abs.times {
        unix_serial << "0"
      }
      cert.serial = unix_serial.to_i
      cert.subject = request.subject
      cert.issuer = SSL.certificate.subject
      cert.public_key = request.public_key
      cert.not_before = Time.now
      cert.not_after = Time.now+(86400*1)
      
      # Prepare to sign
      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = SSL.certificate
      cert.add_extension(ef.create_extension("keyUsage", "digitalSignature,keyEncipherment", true))
      cert.sign(SSL.key, OpenSSL::Digest::SHA1.new)
      
      return cert
    end
    
  end
end