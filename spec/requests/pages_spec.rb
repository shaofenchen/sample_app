require 'spec_helper'

describe "Pages" do
  describe "Home page" do

    it "should have the content 'Sample App'" do
      visit '/'
      page.should have_content('Sample App')
    end
  end
end
