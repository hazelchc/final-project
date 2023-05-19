class ApplicationController < ActionController::Base
  

  def index


    render({ :template => "recipe/leftover.html.erb" })
  end 


  
end
