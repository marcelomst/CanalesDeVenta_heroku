class ReservasController < ApplicationController
  require './wired'
  require 'date'
  require 'json'
  before_action :set_reserva, only: [:edit, :destroy]
  skip_before_action :verify_authenticity_token
  # GET /reservas
  # GET /reservas.json
  def index
    @reservas = Reserva.all
  end

  # GET /reservas/1
  # GET /reservas/1.json
  def show
    @wired = Wired.new
    response_a = @wired.aquire_token
    if response_a['status']=0
      # RECUPERA RESERVAS NUEVAS 
      ancillary= 1
      mark= 0
      response_a = @wired.fetch_new_bookings(ancillary, mark)
    end
    @datetime_com = DateTime.parse('23/08/2018 13:00:00')
    date_inicio_carga = Date.new(2018,8,23)
    imarca = -1
    reservations_a_marcar = Array.new
    respond_to do |format|
      if response_a['status']=0
        
        @response={'status' => response_a['status'],'reservas_a_marcar' => Array.new,'statusmarca' => 0,'response' => Array.new { Hash.new }}
        @i = -1
        response_a['response'].each { |e| 
          if dfrom(e) >= date_inicio_carga
            @reserva = Reserva.find_by(reservation_code: e['reservation_code'])
            
            if  @reserva == nil 
              if not (e['status'] == 5 or e['status'] == 3)

                asigna_response(e)

                @reserva = Reserva.new()

                @reserva.id_channel = e['id_channel']
                # @reserva.special_offer = e['special_offer']
                @reserva.special_offer = ""
                @reserva.reservation_code = e['reservation_code']
                @reserva.arrival_hour = e['arrival_hour']
                @reserva.booked_rate = e['booked_rate']
                @reserva.customer_mail = e['customer_mail']
                @reserva.customer_country = e['customer_country']
                @reserva.children = e['children']
                @reserva.payment_gateway_fee = e['payment_gateway_fee']
                @reserva.customer_surname = e['customer_surname']
                @reserva.date_departure = e['date_departure']
                @reserva.forced_price = e['forced_price']
                @reserva.amount_reason = e['amount_reason']
                @reserva.customer_city = e['customer_city']
                @reserva.opportunities = e['opportunities']
                @reserva.date_received = e['date_received']
                @reserva.was_modified = e['was_modified']
                @reserva.sessionSeed = e['sessionSeed']
                @reserva.customer_name = e['customer_name']
                @reserva.date_arrival = e['date_arrival']
                @reserva.status = e['status']
                @reserva.channel_reservation_code = e['channel_reservation_code']
                @reserva.customer_phone = e['customer_phone']
                @reserva.orig_amount = e['orig_amount']
                @reserva.men = e['men']
                @reserva.customer_notes = e['customer_notes']
                @reserva.customer_address = e['customer_address']
                @reserva.status_reason = e['status_reas']
                @reserva.roomnight = e['roomnight']
                @reserva.customer_language = e['customer_language']
                @reserva.fount = e['fount']
                @reserva.customer_zip = e['customer_zip']
                @reserva.amount = e['amount']
                @reserva.cc_info = e['cc_info']
                @reserva.room_opportunities = e['room_opportunities'] 
                @reserva.customer_language_iso = e['customer_language_iso']
                @reserva.booked_rooms = e['booked_rooms']
                @reserva.booked_rooms = e['booked_rooms'].to_json

                if @reserva.save
                    j = 0
                    err = 0
                    e['rooms_occupancies'].each { |f| 

                      @room = @reserva.rooms.new()
                      @room.id_room = f['id'] 
                      @room.occupancy = f['occupancy']
                      @room.status = 0
                      
                      if not @room.save
                          @response_err = {'status' => -2100, 'response' => "No se pudo salvar el Room de la reserva: #{e['reservation_code']}"}
                          err = 1
                      end
                      j = j + 1
                    }
                    if err == 0
                      # @response['response'][@i]['id']=@reserva['id']
                    else
                      format.json { render :json => @response_err, notice: 'Error al grabar room.'}
                    end
                else
                    # @response['response'][@i]['id']=0
                end
              else
                imarca = imarca + 1
                reservations_a_marcar[imarca] = e['reservation_code']
                @response['reservas_a_marcar'] << e['reservation_code']
              end
            else
              if @reserva['status'] == 6
                # Es una reserva que en la anterior consulta dio overbooking
                # Se va a intentar de nuevo de asignarle habitacion
                if not (e['status'] == 5 or e['status'] == 3) 
                  # No fue cancelada en la ota
                  @reserva['status'] = 1
                  @reserva.save       
                  if  @reserva['id_channel'] != 0
                    asigna_response(e)
                    @response['response'][@i]['id']=@reserva['id']
                  end
                else
                  # En el intervalo que se intento asignar habitacion en Recepcion
                  # y dio Overbooking, en la OTA se cancelo esa reserva, entonces 
                  # simplemente se descarta.
                  imarca = imarca + 1
                  reservations_a_marcar[imarca] = e['reservation_code']
                  @response['reservas_a_marcar'] << e['reservation_code']
                end  
              else
   
                if not (@reserva['status'] == 5 or @reserva['status'] == 3)  or 
                        ((@reserva['status'] == 3 or @reserva['status'] == 5)  and (e['status'] == 1 or e['status'] == 2))
                    if (e['status'] == 5 or e['status'] == 3)
                      @solicitud = Solicitud.find_by(reservation_code_ota: e['reservation_code'], estado: 0) 
                      if @solicitud != nil 
                        # Es una reserva de OTA que fue alterada en la recepcion 
                        # Se debe ajustar la disponibilidad de la reserva OTA alterada
                        # Cuando se altero en recepcion se ajusto la disponibilidad 
                        # incrementando. Al cancelar desde la OTA, el Channel incremento
                        # la disponibilidad y por tanto hay que compensar dsiminuyendo.
                        status_ajusta = ajusta_avail_ota(e) 
                        
                        @solicitud['estado'] = 5
                        id_solicitud = @solicitud['id_solicitud']
                        reservation_code = @solicitud['reservation_code']
                        @solicitud.save
                        # Define si hay  otras alteraciones de la reserva OTA: Se determina buscando 
                        # en solicituds el ultimo  registro de clave "id_solicitud", si el estado es 5 significa
                        # que no se realizaron otras alteraciones 
                        @solicitud = Solicitud.where(["id_solicitud = ?", id_solicitud]).last 
                       
                        if @solicitud['estado'] != 5
                          reservation_code = @solicitud['reservation_code']
                        end 
                        e['reservation_code'] = reservation_code
                        rcode = reservation_code

                        @response_cancel = @wired.cancel_reservation(rcode)
                        
                      end 
                    
                      asigna_response(e)
                      @reserva['status'] = e['status']
                      @reserva.save
                      @response['response'][@i]['id']=@reserva['id']
                    else
                      if @reserva['status'] == 3 and ( e['status'] == 1 or e['status'] == 2)
                        asigna_response(e)
                        @reserva['status'] = e['status']
                        @reserva.save
                        @response['response'][@i]['id']=@reserva['id']
                      end 
                    end
                else
                    @reserva['status'] = e['status']
                    @reserva.save
                end 
                imarca = imarca + 1
                reservations_a_marcar[imarca] = e['reservation_code']
                @response['reservas_a_marcar'] << e['reservation_code']
              end 
            end
          end
        }
        if imarca >= 0
          # @response['statusmarca'] = @wired.mark_bookings(reservations_a_marcar)
        end 
        format.json { render :json => @response, notice: 'Recuperacion de reservas exitosa.'}
      else
        format.json { render json: response_a, status: :unprocessable_entity }
      end
    end
  end
  def asigna_response(e)
    if e['date_received_time'] > @datetime_com
      if e['ancillary']['Referral'] == nil
        referral = ''
      else
        referral = e['ancillary']['Referral']
      end 
      @i = @i + 1
      @response['response'] << {
                'id_channel' => e['id_channel'],
                'reservation_code' => e['reservation_code'],
                'arrival_hour'  => e['arrival_hour'],
                'customer_mail'  => e['customer_mail'],
                'customer_country'  => e['customer_country'],
                'customer_surname'  => e['customer_surname'],
                'rooms_occupancies'  => e['rooms_occupancies'],
                'date_departure'  => e['date_departure'],
                'customer_city'  => e['customer_city'],
                'customer_name'  => e['customer_name'],
                'date_arrival'  => e['date_arrival'],
                'customer_phone'   => e['customer_phone'],
                'customer_notes'  =>  e['customer_notes'],
                'customer_address'  => e['customer_address'],
                'amount'  => e['amount'],
                'booked_rooms' => e['booked_rooms'],
                'status'  => e['status'],
                'referral' => referral}
    end
  end 
  def rooms_a(e)
      # "rooms_occupancies"=>[{"id"=>113348, "occupancy"=>2}]   
      rooms_a = Array.new
      e['rooms_occupancies'].each { |f| 
        if rooms_a.select { |a| a ==  f['id'] }.length == 0
          rooms_a << f['id']
        end 
      }
      rooms_a 
  end
  def ajusta_avail_ota(e)
    # DATOS PARA TEST
      rooms=rooms_a(e)
      dfrom = dfrom(e)
      dto = dto(e) - 1
      
      response = @wired.fetch_rooms_value(dfrom, dto, rooms) 

      if response["status"]=0
        rooms_alt = Array.new(rooms.length) {Hash.new}
        n = 0
        ocur = (dto - dfrom + 1).to_i
        rooms_alt.each { |f|  
              f['id'] = 0
              f['days'] = Array.new(ocur) {Hash.new}
              f['days'].each { |g| 
                g['avail'] =0
              }
          }
        
        m = 0
        e['rooms_occupancies'].each { |f| 
          n = 0
          @stid_room = f['id'].to_s
          i = -1
          @indice_anterior = nil
          rooms_alt.each {|x|
            i = i + 1
            if  x['id'] == f['id']
                @indice_anterior = i
                break
            end
          }
         
          if @indice_anterior == nil 
            rooms_alt[m]['id'] = f['id']
            response['response'][@stid_room].each { |g|  
              rooms_alt[m]['days'][n]['avail'] = g['avail'] - 1
              n = n + 1
            }
            m = m + 1
          else

            rooms_alt[@indice_anterior]['days'].each { |g|  
              g['avail'] = g['avail'] - 1
            }
          end 
            
        }

        response = @wired.update_avail(dfrom, rooms_alt )
    end 
    response['status']
  end
  def dfrom(e)
        arDfrom= e["date_arrival"].split('/').collect! {|n| n.to_i}
        dfrom=Date.new(arDfrom[2],arDfrom[1],arDfrom[0])
  end
  def dto(e)
        arDto= e["date_departure"].split('/').collect! {|n| n.to_i}
        dto=Date.new(arDto[2],arDto[1],arDto[0])
  end
  # GET /reservas/new
  def new
    @reserva = Reserva.new
  end

  # GET /reservas/1/edit
  def edit
  end

  # POST /reservas
  # POST /reservas.json
  def create
   
  end

  # PATCH/PUT /reservas/1
  # PATCH/PUT /reservas/1.json
  def update
    wired = Wired.new
    @response = wired.aquire_token
    respond_to do |format|
      if  @response['status']=0
          i = -1
          reservations = Array.new
          params['reservations'].each { |e|  
            if e['status'] == 0
              i = i + 1
              reservations[i] = e['reservation_code']
            else
              @reserva = Reserva.find_by(reservation_code: e['reservation_code'])
         
              if @reserva != nil
                @reserva.status = e['status']
                @reserva.save
              end
            end 
          }
          if i >= 0
            # @response = wired.mark_bookings(reservations)
            @response['response'] = reservations
          end 
      end
      format.json { render :json => @response}
      
    end
  end

  # DELETE /reservas/1
  # DELETE /reservas/1.json
  def destroy
    @reserva.delete
    respond_to do |format|
      format.html { redirect_to reservas_url, notice: 'Reserva was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reserva
      @reserva = Reserva.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # def reservations_params
    #     # params.permit(reservations:[])
    #     #params.require(:reserva).permit(:id_channel, :special_offer, :reservation_code, :arrival_hour, :booked_rate, :rooms, :customer_mail, :customer_country, :children, :payment_gateway_fee, :customer_surname, :date_departure, :forced_price, :amount_reason, :customer_city, :opportunities, :date_received, :was_modified, :sessionSeed, :customer_name, :date_arrival, :status, :channel_reservation_code, :customer_phone, :orig_amount, :men, :customer_notes, :customer_address, :status_reason, :roomnight, :customer_language, :fount, :customer_zip, :amount, :cc_info, :room_opportunities, :customer_language_iso)
    # end
end
