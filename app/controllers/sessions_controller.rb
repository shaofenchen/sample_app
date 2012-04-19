class SessionsController < ApplicationController

#request	URI			Named route			Action		Purpose
#========================================================================================
#GET		/signin		signin_path			new			page for a new session (signin)
#POST		/sessions	sessions_path		create		create a new session(signed in)
#DELETE		/signout	signout_path		destroy		delete a session (sign out)

  def new
  end
  
  def create
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
	  #render did not count as a new request, redirect_to counts
	  #so we use flash.now
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
end
