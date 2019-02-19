json.array!(@reservas) do |reserva|
  json.extract! reserva, :id, :id_channel, :special_offer, :reservation_code, :arrival_hour, :booked_rate, :rooms, :customer_mail, :customer_country, :children, :payment_gateway_fee, :customer_surname, :date_departure, :forced_price, :amount_reason, :customer_city, :opportunities, :date_received, :was_modified, :sessionSeed, :customer_name, :date_arrival, :status, :channel_reservation_code, :customer_phone, :orig_amount, :men, :customer_notes, :customer_address, :status_reason, :roomnight, :customer_language, :fount, :customer_zip, :amount, :cc_info, :room_opportunities, :customer_language_iso
  json.url reserva_url(reserva, format: :json)
end
