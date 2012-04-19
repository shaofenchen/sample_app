require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_selector('h1',    text: 'Sign in') }
    it { should have_selector('title', text: 'Sign in') }
  end
  
  describe "signin" do

    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector('title', text: 'Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end
	
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email",    with: user.email
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it { should have_selector('title', text: user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }
	  it { should have_link('Settings', href: edit_user_path(user)) }
	  it { should have_link('Users',    href: users_path) }
	  
	  describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
		  #issuing the appropriate HTTP request directly, 
		  #in this case using the put method to issue a PUT request
          specify { response.should redirect_to(signin_path) }
        end
      
	    describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text: 'Sign in') }
        end
	  end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Edit user')
          end
        end
      end	  
	  
    end

	#
    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', text: full_title('Edit user')) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }        
      end
    end
	
	
#--------------------------------
#Rspec test for assignment #10 : 
#1.Users can mark their profiles (/users/n/edit) public or private
#2.Users who are signed in can see all user profiles (/users/n)
#3.Users who are not signed in can see only public profiles
#4.Users who are signed in can see the list of all users (/users/)
#5.Users who are not signed can access the list of all users
#6.But for users who are not signed in, the list of all users contains only users whose profiles are public
#--------------------------------
    describe "viewing user profile" do
      let(:user) { FactoryGirl.create(:user) }
      let(:public_user) { FactoryGirl.create(:user, public_flag: true) }
	  let(:private_user){ FactoryGirl.create(:user) }
	  
      #before { sign_in user }

      describe "as a non-signed-in users" do
	  
		  describe "view the public profile successfully" do
			before { visit public_user(public_user) }
			it { should have_selector('h1',    text: public_user.name) }
			it { should have_selector('title', text: public_user.name) } 
		  end
		  
  		  describe "but can not view the private profile" do
			before { visit public_user(private_user) }
			it { should have_selector('title', text: 'Sign in') }  
		  end
      end
	  
	  describe "as a signed-in users" do
		before { sign_in user }
		describe "view the public profile successfully" do
			before { visit user_path(public_user) }
			it { should have_selector('h1',    text: user.name) }
			it { should have_selector('title', text: user.name) }
		end

		describe "view the private profile successfully" do
			before { visit user_path(private_user) }
			it { should have_selector('h1',    text: user.name) }
			it { should have_selector('title', text: user.name) }
		end
		
      end
	  
    end
	
    describe "viewing user list" do
      let(:user) { FactoryGirl.create(:user) }
      before(:all) { 30.times { FactoryGirl.create(:user, public_flag: true) } }
	  before(:all) { 29.times { FactoryGirl.create(:user) } }
	  after(:all)  { User.delete_all }
	  
      #before { sign_in user }

      describe "as a non-signed-in users" do
	  
		  describe "all the profile except private ones should be display" do
			before { visit users_path }
			  it "should list each public user" do
				User.find_all_by_public_flag(true)[0..29].each do |user|
				  page.should have_selector('li', text: user.name)
				end
			  end
			  
			  it "should not list any private user" do
				User.find_all_by_public_flag(false)[0..29].each do |user|
				  page.should_not have_selector('li', text: user.name)
				end
			  end			  
			  
		  end
      end
	  
	  describe "as a signed-in users" do
		before { sign_in user }
		  describe "all the profile should be display" do
			before { visit users_path }
			  it "should list each public user" do
				User.find_all_by_public_flag(true)[0..29].each do |user|
				  page.should have_selector('li', text: user.name)
				end
			  end
			  
			  it "should list each private user" do
				User.find_all_by_public_flag(false)[0..29].each do |user|
				  page.should have_selector('li', text: user.name)
				end
			  end			  
			  
		  end
      end
	  
    end


	
  end
end
