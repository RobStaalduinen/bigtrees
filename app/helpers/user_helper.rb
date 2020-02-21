module UserHelper
	def sign_in(user)
		session_token = user.session_token
		cookies.permanent[:session_token] = session_token
		self.current_user = user
	end
	
	def sign_out
		cookies.delete(:session_token)
		self.current_user = nil
  end
	
    def current_user=(user)
		@current_user = user
    end
	
	def current_user
		session_token = cookies[:session_token]
		@current_user ||= Arborist.where(session_token: session_token).first			
  end
	
	def signed_in?
		if current_user.blank?
			return false
		else
			return true
		end
	end

	def signed_in_user
		if !signed_in?
			redirect_to login_path
		end
	end

	def signed_in_admin
		if !signed_in? 
			redirect_to login_path
		elsif !current_user.admin?
			redirect_to arborist_path(current_user)
		end
	end
end
