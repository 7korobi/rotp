module ROTP
  class OTP
    attr_reader :secret, :digits, :digest

    # @param [String] secret in the form of base32
    # @option options digits [Integer] (6)
    #     Number of integers in the OTP
    #     Google Authenticate only supports 6 currently
    # @option options digest [String] (sha1)
    #     Digest used in the HMAC
    #     Google Authenticate only supports 'sha1' currently
    # @returns [OTP] OTP instantiation
    def initialize(s, options = {})
      @digits = options[:digits] || 6
      @digest = options[:digest] || "sha1"
      @secret = s
    end

    # @param [Integer] input the number used seed the HMAC
    # @option padded [Boolean] (false) Output the otp as a 0 padded string
    # Usually either the counter, or the computed integer
    # based on the Unix timestamp
    def generate_otp(input, padded=true)
      key = byte_secret.unpack("H*").first
      otp = OtpGenerator.generateWithDigest(@digest, key: key, input: input, digits: @digits)

      if padded
        otp
      else
        otp.to_i
      end
    end

    private

    def verify(input, generated)
      unless input.is_a?(String) && generated.is_a?(String)
        raise ArgumentError, "ROTP only verifies strings - See: https://github.com/mdp/rotp/issues/32"
      end
      input == generated
    end

    def byte_secret
      Base32.decode(@secret)
    end

    # A very simple param encoder
    def encode_params(uri, params)
      params_str = "?"
      params.each do |k,v|
        if v
          params_str << "#{k}=#{CGI::escape(v.to_s)}&"
        end
      end
      params_str.chop!
      uri + params_str
    end

  end
end
