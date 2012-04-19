class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user,     only: :destroy
#request	URI				Action		Named route				Purpose
#========================================================================================
#GET		/users			index		users_path				page to list all users
#GET		/users/1		show		user_path(user)			page to show user with id 1
#GET		/users/new		new			new_user_path			page to make a new user (signup, only page)
#POST		/users			create		users_path				create a new user(save the user)
#GET		/users/1/edit	edit		edit_user_path(user)	page to edit user with id 1
#PUT		/users/1		update		user_path(1)			update user with id 1
#DELETE		/users/1		destroy		user_path(user)			delete user with id 1

  def index
    @users = User.paginate(page: params[:page])
  end


  def show
    @user = User.find(params[:id])
	#local variable is only available in controller, 
	#where as instance variable is available in corresponding views also
	
	#local variable has its scope restriction i.e not available to another methods 
	#where as instance available to another
	
	#instance variable is separate for each object
	
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
	sign_in @user
	flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  
  def edit
  end
  
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end
  
  private


	
    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_path, notice: "Please sign in."
	  #Equal to : flash[:notice] = "Please sign in."
	  #redirect_to signin_path		
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end	

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
