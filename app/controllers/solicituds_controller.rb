class SolicitudsController < ApplicationController
  require './wired'
  require 'date'
  before_action :set_solicitud, only: [:edit]
  skip_before_action :verify_authenticity_token
  
  wrap_parameters format: :json
 
  wrap_parameters Solicitud 


  # GET /solicituds
  # GET /solicituds.json
  def index
    @solicituds = Solicitud.all
  end

  # GET /solicituds/1
  # GET /solicituds/1.json
  def show
  end
  

  # GET /solicituds/new
  def new
    @solicitud = Solicitud.new
  end

  # GET /solicituds/1/edit
  def edit
    
  end

  # POST /solicituds
  # POST /solicituds.json
  def create
    respond_to do |format|
      # CONSOLIDA SOLICITUD EN EL CHANEL
      wired = Wired.new
      wired.aquire_token

      @response = wired.new_reservation(dfrom, dto, rooms, customer, amount)
      # @response={}
      # @response['status'] = 0
      # @response['id'] = 1
      # @response['response'] = '13324563743'
      if  @response['status'] == 0

        @solicitud = Solicitud.new

        @solicitud.id_solicitud = params['id_solicitud'] 
        @solicitud.lname = params['lname'] 
        @solicitud.fname = params['fname'] 
        @solicitud.email = params['email'] 
        @solicitud.city = params['city']
        @solicitud.phone = params['phone'] 
        @solicitud.street = params['street'] 
        @solicitud.country = params['country'] 
        @solicitud.arrival_hour = params['arrival_hour'] 
        @solicitud.notes = params['notes'] 
        @solicitud.amount = params['amount'] 
        @solicitud.rooms = rooms_solicitud
        @solicitud.dfrom = params['from'] 
        @solicitud.dto = params['dto'] 
        @solicitud.reservation_code = @response['response']
        @solicitud.reservation_code_ota = params['reservation_code_ota']       
      
        if @solicitud.save
          format.json { render :json => @response, notice: 'La solicitud fue consolidada al chanel.-'}
        else
          @response['status'] = -2010
          @response['response'] = 'Se consolido la reserva pero no se pudo salvar la solicitud.-'
          format.json { render :json => @response, notice: 'Se consolido la reserva pero no se pudo salvar la solicitud.-'}
        end
      else
        format.json { render :json => @response, notice: 'La solicitud no se pudo consolidar.-'}
      end
    end 
  end
  def amount
    amount = params["amount"].to_i
  end 
  def dfrom
    arDfrom= params["dfrom"].split('/').collect! {|n| n.to_i}
    dfrom=Date.new(arDfrom[2],arDfrom[1],arDfrom[0])
    # dfrom = dfrom + 1
  end 
  def dto
    arDto= params["dto"].split('/').collect! {|n| n.to_i}
    dto=Date.new(arDto[2],arDto[1],arDto[0])
    # dto = dto + 1
  end
  def rooms_solicitud
    rooms_solicitud = {}
    params['rooms'].each { |e| 
        e.each {|key, value|
          rooms_solicitud[key] = value
        }
    }
    rooms_solicitud
  end
  def rooms
    rooms = {}
    params['rooms'].each { |e| 
        e.each {|key, value|
          rooms[key] = [value, 'bb']
        }
    }
     rooms
     # rooms = "#{rooms}#{coma}#{e.key} => [#{e[e.key]}, 'bb']"
  end 
  def customer
    customer = {'lname' => params['lname'], 
                'fname' => params['fname'], 
                'email' => params['email'], 
                'city' => params['city'], 
                'phone' => params['phone'], 
                'street' => params['street'],
                'country' => params['country'],
                'arrival_hour' => params['arrival_hour'],
                'notes' => params['notes']}
  end

  # PATCH/PUT /solicituds/1
  # PATCH/PUT /solicituds/1.json
  def update
    wired = Wired.new
   
    respond_to do |format|
      @response = wired.aquire_token
 
      if @response["status"]=0
        #{dfrom, dto, 'rooms' => [{'id_room' => 113348, 'incremento' => 1},{'id_room' => 113301, 'incremento' => -1}]}
    
        @response = wired.fetch_rooms_value(dfrom, dto, rooms_a) 

        if @response["status"]=0
          rooms_alt = Array.new(params['rooms'].length) {Hash.new}
          n = 0
          ocur = (dto - dfrom + 1).to_i
          rooms_alt.each { |e|  
            e['id'] = 0
            e['days'] = Array.new(ocur) {Hash.new}
            e['days'].each { |f| 
              f['avail'] =0
            }
          n=n+1
          }
   
          m = 0
          err = 0
          @response_err=Hash.new
          @response_err['status'] = 0
          params['rooms'].each { |e| 
            n = 0
            stid_room=e['id_room'].to_s
            rooms_alt[m]['id']=e['id_room']
            @response['response'][stid_room].each { |f|  
              rooms_alt[m]['days'][n]['avail']=f['avail']+e['incremento']
              if rooms_alt[m]['days'][n]['avail'] < 0
                @response_err['status'] = -2000
                @response_err['response'] = "No hay disponiblidad para la habitacion."
                err=1
              end 
              n = n + 1
            }
            
            m = m + 1
          }
          if err == 0

            @response = wired.update_avail(dfrom, rooms_alt )

            if @response["status"]=0
              format.json { render :json => @response, notice: 'Se actualizaron las disponibilidades.' }
            else
              format.json { render :json => @response, notice: 'Error en la actualizacion de disponibilidad.' }
            end
          else
            format.json { render :json => @response_err, notice: 'No hay disponibilidad.' }
          end 
        else          
          format.json { render :json => @response, notice: 'Error en la consulta de room.' }
        end
      else
        format.json { render :json => @response, notice: 'Error en la conexion al channel.' }
      end
     
    end
  end 
  def rooms_a
      rooms_a= Array.new(params['rooms'].length)
      n = 0
      params['rooms'].each { |e| 
        rooms_a[n] = e['id_room']
        n = n + 1
      } 
      rooms_a 
  end 
  def rcode
    rcode=params["reservation_code"]
  end

  # DELETE /solicituds/1
  # DELETE /solicituds/1.json
  def destroy
    respond_to do |format|
      # CANCELA RESERVA
      wired = Wired.new
      wired.aquire_token

      @response = wired.cancel_reservation(rcode)

      format.json { render :json => @response, notice: 'La cancelacion  fue consolidada al chanel.' }
    end 
  end
  def ajusta_avail
      @response = wired.fetch_rooms_value(dfrom, dto, rooms_a) 
      if @response["status"]=0
        @reserva = Reserva.find_by(reservation_code: rcode)
        if  @reserva != nil 
            
            id_reserva = @reserva['id']
            err = 0
            j = 0
            params['rooms'].each { |e|  
                room_act = Room.where(reserva_id: id_reserva, id_room: e['id_room'])    
                if  room_act != nil
                    e['days'].each { |f| 
                        f['incremento'] = f['incremento'] 
                    }
                    room_act['']
                else
                    err = 1  
                end  
                j = j + 1
            }
            if err == 0

            else
                response_err = {'status' => -2020, 'response' => "No se encontro el room de la reserva en el servidor"}
                format.json { render :json => response_err, notice: 'No se pudo consultar los valores de room.' } 
            end
        else
          response_err = {'status' => -2010, 'response' => "No se encontro la reerva en el servidor"}
          format.json { render :json => response_err, notice: 'No se pudo consultar los valores de room.' } 
        end 
      else
        format.json { render :json => @response, notice: 'No se pudo consultar los valores de room.' } 
      end 
  end 
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_solicitud
      @solicitud = Solicitud.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # def solicitud_params
    #   params.require(:solicitud).permit(:id_solicitud, :lname, :fname, :email, :city, :phone, :street, :country, :arrival_hour, :notes, :amount, :rooms, :dfrom, :dto, :reservation_code)
    # end
end
