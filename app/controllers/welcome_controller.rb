class WelcomeController < ApplicationController
  # GET /welcome
  # require 'C:\canalesDeVenta\wired'
  require './wired'
  require 'date'
  def index
    wired = Wired.new
    wired.aquire_token
    ancillary= 1
    mark= 0
        
   @response = wired.fetch_new_bookings(ancillary, mark)
  

  end

end
