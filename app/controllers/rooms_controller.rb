class RoomsController < ApplicationController

  require './wired'
  require 'date'
  
  before_action :set_room, only: [:show, :edit, :destroy]

  # skip_before_filter  :verify_authenticity_token 
  skip_before_action :verify_authenticity_token
  
  wrap_parameters format: :json
  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params)

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    dfrom_p = dfrom
    dto_p = dto
    wired = Wired.new
    @response=wired.aquire_token
    respond_to do |format|
      if @response['status'] = 0
    
     
        if params['reservation_code'] != 0

          @reserva = wired.fetch_booking(params['reservation_code']) 

          if @reserva['response'][0]['id_channel'] == 0  
            @response = wired.cancel_reservation(params['reservation_code'])
          end    
          dfrom_r = ctod(@reserva['response'][0]['date_arrival'])
          dto_r = ctod(@reserva['response'][0]['date_departure'])-1
        else
          dfrom_r = dfrom_p
          dto_r =  dto_p
        end 

        if dfrom_p >  dfrom_r 
          dfrom_a=  dfrom_r
        else
          dfrom_a=  dfrom_p
        end 
                  
        if  dto_p <  dto_r
          dto_a=   dto_r
        else
          dto_a=   dto_p
        end 
        @dfrom_a = dfrom_a
        ndias = dto_a - dfrom_a + 1
                
                
        # @matr_pms =  [{'142498'=> [1, 1,0]},{'113301' => [1,1,1]}, {'142495' => [0,0,0]}]
        # @matr_room = [{'142498'=> [1, 1,0]},{'113301' => [0,0,0]}, {'142495' => [1,1,0]}]
        # @matr_resta = [{'142498'=> [0, 0,0]},{'113301' => [1,1,1]}, {'142495' => [-1,-1,0]}] = @matr_pms - @matr_room
        @matr_pms = Array.new()
        @matr_room = Array.new()
        @matr_resta = Array.new()
        @matr_channel = Array.new()
        i = - 1
        params['rooms'].each { |e| 
            e.each {|key, value| 
              i = i + 1
              @matr_pms.push(Hash.new)
              @matr_pms[i] [key] = Array.new(ndias)
              @matr_pms[i] [key].fill(0)

              @matr_room.push(Hash.new)
              @matr_room[i] [key] = Array.new(ndias)
              @matr_room[i] [key].fill(0)

              @matr_resta.push(Hash.new)
              @matr_resta[i] [key] = Array.new(ndias)
              @matr_resta[i] [key].fill(0)

              @matr_channel.push(Hash.new)
              @matr_channel[i] [key] = Array.new(ndias)
              @matr_channel[i] [key].fill(0)
            }
        }
              
        nrooms = params['rooms'].length

        if params['reservation_code'] != 0
          # Room.where(reserva_id: @reserva.id).find_each do |room|
          @reserva['response'][0]['rooms_occupancies'].each { |room|  
            esta = false
            @matr_pms.each { |e| 
                e.each {|key, value| 
                  if key.to_i == room['id']
                    esta = true
                    break
                  end
                }
              }  
              if esta == false
                nrooms = nrooms + 1
                i = i + 1
                @matr_pms.push(Hash.new)
                @matr_pms[i] [room['id'].to_s] = Array.new(ndias)
                @matr_pms[i] [room['id'].to_s].fill(0)

                @matr_room.push(Hash.new)
                @matr_room[i] [room['id'].to_s] = Array.new(ndias)
                @matr_room[i] [room['id'].to_s].fill(0)

                @matr_resta.push(Hash.new)
                @matr_resta[i] [room['id'].to_s] = Array.new(ndias)
                @matr_resta[i] [room['id'].to_s].fill(0)

                @matr_channel.push(Hash.new)
                @matr_channel[i] [room['id'].to_s] = Array.new(ndias)
                @matr_channel[i] [room['id'].to_s].fill(0)
              end 
          }  
          @matr_room.each { |e| 
            e.each {|key, value|
              # Room.where(reserva_id: @reserva.id, id_room: key.to_i).find_each do |room|
              @reserva['response'][0]['rooms_occupancies'].each { |room| 
                if room['id'].to_s == key
                  j = -1
                  date_a = dfrom
                  while date_a <= dto
                    j = j + 1
                    if date_a >= dfrom_r
                      if  date_a <= dto_r
                        value[j] = value[j] + 1
                      end
                    end 
                    date_a = date_a + 1
                 end
                end 
              }
            }
          }
        end 
                
                         
        i = -1
        params['rooms'].each { |e| 
          e.each {|key, value|
            i = i + 1
            j = -1
            z = -1
            date_a = dfrom
            while date_a <= dto
              j = j + 1
              if date_a < dfrom_p
                @matr_pms[i][key][j] = 0
              else
                if  date_a > dto_p
                  @matr_pms[i][key][j] = 0
                else
                  z = z + 1
                  @matr_pms[i][key][j] = value[z]
                end
              end 
              date_a = date_a + 1
            end
          }
        }

        i = -1
        @matr_resta.each { |e| 
          e.each {|key,value|
            i = i + 1
            j = - 1
            while j <= ndias-2
              j = j + 1
              value[j] = @matr_pms[i][key][j] - @matr_room[i][key][j] 
            end 
                    
          }
        }

        rooms_fetch= Array.new(@matr_resta.length)
        n = 0
        @matr_resta.each { |e| 
          e.each {|key,value| 
            rooms_fetch[n] = key.to_i
            n = n + 1
          } 
        }

        rooms_a= Array.new(@matr_resta.length)
          n = 0
          @matr_resta.each { |e| 
            e.each {|key,value| 
              rooms_a[n] = key.to_i
              n = n + 1
          } 
        }

        

        # respond_to do |format|

        ocur = (dto_a - dfrom_a + 1).to_i 
        rooms_alt = Array.new(@matr_resta.length) {Hash.new}

        if params['operacion'] == 1
        
          @response = wired.fetch_rooms_value(dfrom_a, dto_a, rooms_fetch)

          if @response['status']=0
                
              @matr_channel.each { |e| 
                e.each {|key,value|
                  j = - 1
                  while j <= ocur-2
                    j = j + 1
                    value[j] = @response['response'][key][j]['avail'] 
                  end 
                
                }
              }
                     
              n = 0
              @matr_resta.each { |e|  
                e.each { |key, value|
                  rooms_alt[n]['id'] = key.to_i
                  rooms_alt[n]['days'] = Array.new(ocur) {Hash.new}
                  i = 0
                  rooms_alt[n]['days'].each { |f| 
                    f['avail'] =  @response['response'][key][i]['avail'] + value[i] 
                    i = i + 1
                  }
                }
                n = n + 1
              }
              @response = wired.update_avail(dfrom_a, rooms_alt )
              # @response = rooms_alt
              if @response["status"]=0
              # if 1 == 1
                format.json { render :json => @response, notice: 'Se actualizaron las disponibilidades.' }
              else
                format.json { render :json => @response, notice: 'Error en la actualizacion de disponibilidad.' }
              end
          else
            format.json { render :json => @response, notice: 'Error en la consulta de room .' }
          end
        else
          n = 0
          @matr_resta.each { |e|  
            e.each { |key, value|
              rooms_alt[n]['id'] = key.to_i
              rooms_alt[n]['days'] = Array.new(ocur) {Hash.new}
              i = 0
              rooms_alt[n]['days'].each { |f| 
                f['avail'] =  value[i] 
                i = i + 1
              }
            }
            n = n + 1
          }
          
          @response = wired.update_avail(dfrom_a, rooms_alt )

          # @response = rooms_alt
          if @response['status']=0
          # if 1 == 1
            format.json { render :json => @response, notice: 'Se actualizaron las disponibilidades.' }
          else
            format.json { render :json => @response, notice: 'Error en la actualizacion de disponibilidad.' }
          end
        end
        # end 
      else
        format.json { render :json => @response, notice: 'Error en la conexion al channel.' }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  def actualiza_avail(dfrom_a, dto_a)

      
  end 
  def dfrom
    arDfrom= params["dfrom"].split('/').collect! {|n| n.to_i}
    dfrom=Date.new(arDfrom[2],arDfrom[1],arDfrom[0])
  end 
  def dto
    arDto= params["dto"].split('/').collect! {|n| n.to_i}
    dto=Date.new(arDto[2],arDto[1],arDto[0])
  end
  def ctod(cdate)
    arDto= cdate.split('/').collect! {|n| n.to_i}
    dto=Date.new(arDto[2],arDto[1],arDto[0])
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # def room_params
    #   params.require(:room).permit(:id_room, :occupancy, :status)
    # end
end
