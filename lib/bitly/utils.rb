module Bitly
  module Utils
    private
    def underscore(camel_cased_word) # stolen from rails
      camel_cased_word.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end
    
    def attr_define(k,v)
      instance_variable_set("@#{k}", v)
      meta = class << self; self; end
      meta.class_eval { attr_reader k.to_sym }
    end

    def instance_variablise(obj,variables)
      if obj.is_a? Hash
        obj.each do |k,v|
          if v.is_a? Hash
            instance_variablise(v,variables)
          else
            attr_define(underscore(k),v) if variables.include?(underscore(k))
          end
        end
      end
    end
    
    def create_url(resource="",args={})
      args = args.merge({:login => @login, :apiKey => @api_key, :version => API_VERSION})
      url = URI.join(API_URL,resource)
      long_urls = args.delete(:long_urls)
      url.query = args.map { |k,v| "%s=%s" % [URI.encode(k.to_s), URI.encode(v.to_s)] }.join("&")
      url.query << "&" + long_urls.map { |long_url| "longUrl=#{URI.encode(long_url)}" }.join("&") unless long_urls.nil?
      url
    end
    
    def get_result(request)
      result = JSON.parse(Net::HTTP.get(request))
      if result['statusCode'] == "OK"
        result = result['results']
      else
        raise BitlyError.new(result['errorMessage'],result['errorCode'],'expand')
      end
    end
    
  end
end