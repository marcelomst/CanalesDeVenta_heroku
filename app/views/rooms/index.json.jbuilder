json.array!(@rooms) do |room|
  json.extract! room, :id, :id_room, :occupancy, :status
  json.url room_url(room, format: :json)
end
