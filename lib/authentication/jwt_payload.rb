module Authentication
  class JwtPayload
    attr_reader :jti, :exp, :iat, :user

    def initialize(user)
      @user   = user
      @iat    = Time.zone.now
      jti_raw = [JsonWebToken.secret, user.email, iat.inspect].join(':').to_s
      @jti    = Digest::MD5.hexdigest(jti_raw)
      @exp    = iat + user.token_duration.seconds
    end

    def as_json
      {
        user: @user.as_json,
        iss: JsonWebToken::ISSUER,
        exp: exp.to_i,
        iat: iat.to_i,
        jti: jti
      }
    end
  end
end