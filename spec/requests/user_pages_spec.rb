require 'spec_helper'

describe "User pages" do

  subject { page }
  
# index
  describe "index" do
    # before do
      # sign_in FactoryGirl.create(:user)
      # FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
      # FactoryGirl.create(:user, name: "Ben", email: "ben@example.com")
      # visit users_path
    # end

    # it { should have_selector('title', text: 'All users') }

    # it "should list each user" do
      # User.all.each do |user|
        # page.should have_selector('li', text: user.name)
      # end
    # end
	
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    it { should have_selector('title', text: 'All users') }

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
	  #before(:each) blocks are run before each example, before(:all) blocks are run once before all of the examples in a group
      after(:all)  { User.delete_all }

      it { should have_link('Next') }
      its(:html) { should match('>2</a>') }
	  #which test for a link containing then number 2 and only the number 2
	  #equal to: it { should have_link('2') }

      it "should list each user" do
        User.all[0..2].each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
	  
    end	
	
    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  
 
  end
  
  
  
# signup page  
  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }
	
    it { should have_selector('title', text: full_title('Sign up')) }
 #"include ApplicationHelper" in spec/support/utilities, so full_title here works
 
  end
 
 #user factory defined in spec/factories.rb
 #Testing with bcrypt is slow by default configuration, config in config/environments/test.rb make it fast
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
  end
  
  
  
  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
	  
	describe "error messages" do
        before { click_button submit }

        it { should have_selector('title', text: 'Sign up') }
        it { should have_content('error') }
     end
	 
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
		#change method takes as arguments an object and a symbol and then calculates the result of 
		#calling that symbol as a method on the object both before and after the block.
      end
	  
	  
	 describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
		it { should have_link('Sign out') }
	 
     end

    end
	
	
  end
  
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_selector('h1',    text: "Update your profile") }
      it { should have_selector('title', text: "Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
	  it { should have_unchecked_field('user_public_flag') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }

      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
	  #This code reloads the user variable from the test database using user.reload
	  
    end

  end  
  
  
  
end