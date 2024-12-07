module ResponseHelper
    extend ActiveSupport::Concern
  
    # Success response
    def success_response(message: 'Success', data: {}, status: :ok)
      render json: {
        success: true,
        message: message,
        data: data
      }, status: status
    end
  
    # Error response
    def error_response(message: 'Error', errors: [], status: :unprocessable_entity)
      render json: {
        success: false,
        message: message,
        errors: errors
      }, status: status
    end

    def server_error_response(message: 'Error', errors: [])
      render json: {
        success: false,
        message: message,
        errors: errors
      }, status: :internal_server_error
    end
end