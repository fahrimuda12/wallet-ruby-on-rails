class SessionsController < ApplicationController
  include ResponseHelper
  # require 'services/jwt_service'
  require_relative '../services/jwt_service'


  # POST /api/login
  def login
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      # Buat token session sederhana (misal, timestamp dengan username hashed)
      token = generate_session_token(user)
      # session[:user_id] = user.id
      success_response(message: 'Login successful', data: { token: token })
    else
      error_response(message: 'Invalid username or password')
    end
  end

  def register
    user = User.new(username: params[:username], password: params[:password])

    if user.save
      success_response(message: 'User created successfully')
    else
      error_response(message: 'Failed to create user', errors: user.errors.full_messages)
    end
  end

  # DELETE /api/logout
  def logout
    # session.delete(:user_id)
    # Jika session token digunakan, logic bisa ditambahkan untuk invalidasi
    success_response(message: 'Logout successful')
  end

  private

  def generate_session_token(user)
    JwtService.encode(user_id: user.id)
  end
end