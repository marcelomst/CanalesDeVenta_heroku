require 'rubygems'
require 'xmlrpc/client'
# require 'xmlparser'
require 'date'
# class XMLRPC::Client
#   def set_debug
#     @http.set_debug_output($stderr);
#   end
# end

# Implementation of the WuBook API. 
# The Documentation can be found here: https://sites.google.com/site/wubookdocs/wired/wired-pms-xml
class Wired
  def initialize
    # The config will contain the following keys: account_code, password, provider_key
    @config = {   'account_code' => 'MM380',
                  'password' => '94267',
                  'provider_key' => './cx.kuf0s9rio32j'
              }
    @lcode=1432041228
    self.server
  end
  
  def config
    @config
  end

  # Requests a token from the server. 
  # The token is stored in this object and will be used automatically.
  def aquire_token
    if !(is_token_valid($token))
      token_data = server.call("acquire_token", @config['account_code'], @config['password'], @config['provider_key'])
      status = token_data[0]
      $token = token_data[1]
      if (is_error(status)) 
        error_message = decode_error(status)
        raise "Unable to aquire token. Reason: #{error_message}, Message: #{data}"
      end
    end
    handle_response($token, "No se pudo acceder al Token")
  end

  def is_token_valid(token = $token)
    if token != nil
      response = server.call("is_token_valid", token)
      status = response[0]
    else
      status = -1
    end 
    status == 0
  end

  # Releases the token fetched by #aquire_token
  def release_token(token = $token)
    response = server.call("release_token", token)

    handle_response(response, "Unable to release token")
    $token = nil
  end
  def push_url(lcode = @lcode, token = $token)
     response = server.call("push_url", token, lcode)

     handle_response(response, "No se pudo obtener la URL")
  end 
  # Fetch rooms
  def fetch_rooms(lcode = @lcode, token = $token)
    response = server.call("fetch_rooms", token, lcode)
    
    handle_response(response, "Unable to fetch room data")
  end
  # Fetch rooms
  def fetch_rooms_value(dfrom, dto, rooms, lcode = @lcode, token = $token)
    
    response = server.call("fetch_rooms_values", token, lcode, dfrom.strftime('%d/%m/%Y'), dto.strftime('%d/%m/%Y'), rooms)
    
    handle_response(response, "Unable to fetch room data")
  end
  # Update room values
  # ==== Attributes
  # * +dfrom+ - A Ruby date object (start date)
  # * +rooms+ - A hash with the following structure: [{'id' => room_id, 'days' => [{'avail' => 0}, {'avail' => 1}]}]
  def update_rooms_values( dfrom, rooms,lcode = @lcode, token = $token)
    response = server.call("update_rooms_values", token, lcode, dfrom, rooms)

    handle_response(response, "Unable to update room data")
  end

  def update_avail( dfrom, rooms, lcode = @lcode, token = $token)
    response = server.call("update_avail", token, lcode, dfrom.strftime('%d/%m/%Y'), rooms)

    handle_response(response, "Unable to update room data")
  end
  
  def new_reservation(  dfrom, dto, rooms, customer, amount, lcode = @lcode, token = $token )
    response = server.call("new_reservation", token, lcode, dfrom.strftime('%d/%m/%Y'), dto.strftime('%d/%m/%Y'), rooms, customer, amount)

    handle_response(response, "Unable to do new reservation")
  end

  def cancel_reservation(rcode, lcode = @lcode, token = $token )

    response = server.call("cancel_reservation", token, lcode, rcode)

    handle_response(response, "Unable to cancel reservation")
  end
  def fetch_booking(rcode, ancillary = 1, lcode = @lcode, token = $token)

    response = server.call("fetch_booking", token, lcode, rcode, ancillary)

    handle_response(response, "Unable to fetch reservation")
   
  end
  def fetch_new_bookings(ancillary, mark, lcode = @lcode, token = $token)
    #fetch_new_bookings(token, lcode[, ancillary= 0, mark= 1])
    response = server.call("fetch_new_bookings", token, lcode, ancillary, mark)

    handle_response(response, "Unable to fetch new reservation")
  end
  def  mark_bookings(reservations, lcode = @lcode, token = $token)
    response = server.call("mark_bookings", token, lcode, reservations)

    handle_response(response, "Unable to mark reservations")  
  end
  
  # Request data about rooms.
  # ==== Attributes
  # * +dfrom+ - A Ruby date object (start date)
  # * +dto+ - A Ruby date object (end date)
  # * +rooms+ - An array containing the requested room ids
  def fetch_rooms_values(dfrom, dto, rooms = nil, lcode = @lcode, token = $token)
    if rooms != nil then
      response = server.call("fetch_rooms_values", token, lcode, dfrom.strftime('%d/%m/%Y'), dto.strftime('%d/%m/%Y'), rooms)
    else
      response = server.call("fetch_rooms_values", token, lcode, dfrom.strftime('%d/%m/%Y'), dto.strftime('%d/%m/%Y'))
    end

    handle_response(response, "Unable to fetch room values")
  end

  protected

  # def handle_response(response, message)
  #   status = response[0]
  #   data   = response[1]
  #   if (is_error(status)) 
  #     error_message = decode_error(status)
  #     raise "#{message}. Reason: #{error_message}, Message: #{data}"
  #   end
  #   data
  # end
  def handle_response(response, message)
    status = response[0]
    if (is_error(status)) 
      data = {'status' => status, 'response' => "#{message}. Reason: #{response[1]}"}
    else
      data = {'status' => status, 'response' => response[1]}
    end 
    data
  end
  def decode_error(code)
    codes = {
     0    => 'Ok',
     -1    => 'Authentication Failed',
     -2    => 'Invalid Token',
     -3    => 'Server is busy: releasing tokens is now blocked. Please, retry again later',
     -4    => 'Token Request: requesting frequence too high',
     -5    => 'Token Expired',
     -6    => 'Lodging is not active',
     -7    => 'Internal Error',
     -8    => 'Token used too many times: please, create a new token',
     -9    => 'Invalid Rooms for the selected facility',
     -10   => 'Invalid lcode',
     -11   => 'Shortname has to be unique. This shortname is already used',
     -12   => 'Room Not Deleted: Special Offer Involved',
     -13   => 'Wrong call: pass the correct arguments, please',
     -14   => 'Please, pass the same number of days for each room',
     -15   => 'This plan is actually in use',
     -100  => 'Invalid Input',
     -101  => 'Malformed dates or restrictions unrespected',
     -1000 => 'Invalid Lodging/Portal code',
     -1001 => 'Invalid Dates',
     -1002 => 'Booking not Initialized: use facility_request()',
     -1003 => 'Objects not Available',
     -1004 => 'Invalid Customer Data',
     -1005 => 'Invalid Credit Card Data or Credit Card Rejected',
     -1006 => 'Invalid Iata',
     -1007 => 'No room was requested: use rooms_request()' 
    }
    codes[code]
  end

  def server
    server = XMLRPC::Client.new2("https://wired.wubook.net/xrws/")
    # server.set_debug
    # server.set_parser(XMLRPC::XMLParser::XMLStreamParser.new)
    server
  end


  def is_error(code)
    code.to_i < 0
  end
end

