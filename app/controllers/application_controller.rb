class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def set_mailer_host
    if Rails.env.development?
      subdomain = current_account ? "#{current_account.subdomain}." : ""
      ActionMailer::Base.default_url_options[:host] = "#{subdomain}lvh.me:5000"
    else
      subdomain = current_account ? "#{current_account.subdomain}." : ""
      ActionMailer::Base.default_url_options[:host] = "#{subdomain}canalesdeventa.herokuapp.com"
    end
  end 
end
