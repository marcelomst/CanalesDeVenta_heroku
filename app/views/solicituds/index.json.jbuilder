json.array!(@solicituds) do |solicitud|
  json.extract! solicitud, :id, :id_solicitud, :lname, :fname, :email, :city, :phone, :street, :country, :arrival_hour, :notes, :amount, :id_room, :cantidad
  json.url solicitud_url(solicitud, format: :json)
end
