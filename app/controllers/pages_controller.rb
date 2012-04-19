class PagesController < ApplicationController

  def home
    @title = "Home"
  end
  
    def help
    @title = "Help"
  end

  def contact
    @title = "Contact"
  end

  def about
    @title = "About"
  end
       
end
##
