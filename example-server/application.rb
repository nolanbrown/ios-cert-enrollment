require 'rubygems'
require 'sinatra'
require 'ios-cert-enrollment'

require 'sinatra/base'
require 'webrick'
require 'webrick/https'
require 'openssl'

IOSCertEnrollment.configure do |config|
  config.ssl_certificate_path = "<PATH TO SSL CERTIFICATE>"
  config.ssl_key_path = "<PATH TO SSL PRIVATE KEY>"
  config.base_url = "<YOUR URL>"
  config.identifier = "com.nolanbrown"
  config.display_name = "iOS Enrollment Server"
  config.organization = "Nolan Brown"
end

webrick_options = {
        :Port               => 8443,
        :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
        :DocumentRoot       => "/ruby/htdocs",
        #:DoNotReverseLookup => false,
        :SSLEnable          => true,
        :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
        :SSLCertificate     => IOSCertEnrollment::SSL.certificate,
        :SSLPrivateKey      => IOSCertEnrollment::SSL.key,
        :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ]
}

class MyServer < Sinatra::Base

  get '/' do
    '<a href="/enroll">Enroll</a>'
  end

  get '/enroll' do 
    signed_certificate = IOSCertEnrollment::Profile.new("/profile").service().sign()

    ## Send
    content_type signed_certificate.mime_type
    signed_certificate.certificate  

  end

  post '/profile' do  
    p7sign = IOSCertEnrollment::Sign.verify_response(request.body.read)
    if IOSCertEnrollment::Sign.verify_signer(p7sign)
      
      profile = IOSCertEnrollment::Profile.new()
      profile.icon = File.open(File.expand_path('<PATH TO YOUR ICON>', __FILE__))
      profile.display_name = "iOS Enrollment Server"
      profile.description = "Easy access to web"
      profile.label = "iOS Enrollment"
      profile.url = "<URL FOR WEBCLIP>"
      encrypted_profile = profile.webclip().encrypt(p7sign.certificates)
      signed_profile = profile.configuration(encrypted_profile.certificate).sign()
      
    else
      # Get returned device attributes
      device_attributes = IOSCertEnrollment::Device.parse(p7sign)  

      # "UDID", 
      # "VERSION",
      # "PRODUCT",          
      # "DEVICE_NAME",
      # "MAC_ADDRESS_EN0",
      # "IMEI",
      # "ICCID"
      
      ## Validation
      profile = IOSCertEnrollment::Profile.new("/scep")
      signed_profile = profile.encrypted_service().sign()

    end
    ## Send 
    content_type signed_profile.mime_type
    signed_profile.certificate

  end

  get '/scep' do
    case params['operation']
    when "GetCACert"
      registration_authority = IOSCertEnrollment::Sign.registration_authority
      content_type registration_authority.mime_type
      registration_authority.certificate

    when "GetCACaps" 
      content_type "text/plain"
      IOSCertEnrollment::Sign.certificate_authority_caps
    else
      "Invalid Action"
    end
  end

  post '/scep' do
    if params['operation'] == "PKIOperation"
      signed_pki = IOSCertEnrollment::Sign.sign_PKI(request.body.read)

      content_type signed_pki.mime_type
      signed_pki.certificate

    else
      "Invalid Action"
    end
  end      
end

Rack::Handler::WEBrick.run MyServer, webrick_options



