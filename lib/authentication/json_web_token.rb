# frozen_string_literal: true

module Authentication
  ##
  # Authenticatin JWTs and issueing new tokens with the withelist strategy.
  #
  # TODO:
  # 1) Implement a refresh strategy:
  #    a) User can allow refresh of tokens when used
  #    b) Touch updated at when authenticating and return a new JWT
  #    c) Update the exo variable
  # 2) Implement ip check such that IP does not change once issued (if user requires this)
  class JsonWebToken < Warden::Strategies::Base
    ALGORITHM         = 'HS256'
    ISSUER            = 'POSTER_SHOP'
    DECODE_EXCEPTIONS = [
      JWT::ExpiredSignature,
      JWT::InvalidIssuerError,
      JWT::InvalidJtiError,
      JWT::InvalidIatError,
      JWT::DecodeError,
    ].freeze

    ##
    # TODO: ensure an env setup persisting this secret in production
    def self.secret
      ENV['JWT_SECRET'] ||= SecureRandom.base64
    end

    ##
    # Creating a JWT and storing the JTI for a given user with a request
    def self.create(user, request)
      iat     = Time.zone.now
      jti_raw = [secret, user.email, iat.inspect].join(':').to_s
      jti     = Digest::MD5.hexdigest(jti_raw)
      exp     = iat + user.token_duration.seconds
      payload = {
        user: user.as_json,
        iss: ISSUER,
        exp: exp.to_i,
        iat: iat.to_i,
        jti: jti
      }
      token = JWT.encode(payload, secret, ALGORITHM)

      Jti.create(
        user_id: user.id,
        jti: jti,
        exp: exp,
        agent: request.env['HTTP_USER_AGENT']
      )

      token
    end

    ##
    # Decoding a JWT and finding associated JTI.
    def self.decode(token)
      decoded, _alg = JWT.decode(token, secret, true, {
        algorithm: ALGORITHM,
        iss: ISSUER,
        verify_iss: true,
        verify_iat: true,
        verify_jti: proc do |jti, payload|
                      @jti = Jti.signed_with(jti: jti, user_id: payload['user']['id'])
                    end
      })
      [decoded, @jti]
    end

    ##
    # Notice that request object may not be fully formed, go directly to HTTP
    def token
      env['HTTP_AUTHORIZATION']
    end

    def valid?
      !token.blank?
    end

    def agent_changed?
      @jti.agent != env['HTTP_USER_AGENT']
    end

    def authenticate!
      begin
        @decoded, @jti = self.class.decode(token)
      rescue *DECODE_EXCEPTIONS => e
        return fail!(e)
      end

      @current_user = User.new(@decoded['user'])

      if agent_changed?
        @jti.destroy
        return fail!('Agent changed')
      end

      success!([@current_user, @decoded, @jti])
    end
  end
end
