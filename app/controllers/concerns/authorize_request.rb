module AuthorizeRequest
  extend ActiveSupport::Concern

  included do
    before_action :authorize_request
  end

  private

  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    # Periksa apakah token ada
    if token.nil?
      render_unauthorized('Token is missing')
      return
    end

    # decode token
    decoded_token = JwtService.decode(token)

    # Validasi token
    # @current_session = Session.find_by(token: token)
    # if @current_session.nil? || @current_session.expires_at < Time.current
    #   render_unauthorized('Invalid or expired token')
    #   return
    # end
    if decoded_token.nil?
      render_unauthorized('Invalid or expired token')
      return
    end

    # Simpan user saat token valid
    # @current_user = @current_session.user
    @current_user = User.find_by(id: decoded_token[:user_id])
    if @current_user.nil?
      render_unauthorized('Invalid or expired token')
    end
  end

  def render_unauthorized(message)
    error_response(message: message, errors: [], status: :unauthorized)
  end

  # Mendapatkan user yang sedang login
  def current_user
    @current_user
  end
end
