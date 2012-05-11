require File.expand_path('../configuration', __FILE__)
require File.expand_path('../certificate', __FILE__)
require File.expand_path('../ssl', __FILE__)

require "plist"

module IOSCertEnrollment
  module Device        
    class << self    
      def parse(p7sign)
        return Plist::parse_xml(p7sign.data)
      end
    end
  end
end