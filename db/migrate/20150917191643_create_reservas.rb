class CreateReservas < ActiveRecord::Migration
  def change
    create_table (:reservas) do |t|
     
      t.integer :id_channel
      t.string :special_offer
      t.bigint :reservation_code
      t.string :arrival_hour
      t.integer :booked_rate
      t.string :rooms
      t.string :customer_mail
      t.string :customer_country
      t.integer :children
      t.string :payment_gateway_fee
      t.string :customer_surname
      t.string :date_departure
      t.integer :forced_price
      t.string :amount_reason
      t.string :customer_city
      t.integer :opportunities
      t.string :date_received
      t.integer :was_modified
      t.string :sessionSeed
      t.string :customer_name
      t.string :date_arrival
      t.integer :status
      t.string :channel_reservation_code
      t.string :customer_phone
      t.float :orig_amount
      t.integer :men
      t.string :customer_notes
      t.string :customer_address
      t.string :status_reason
      t.integer :roomnight
      t.integer :customer_language
      t.string :fount
      t.string :customer_zip
      t.float :amount
      t.integer :cc_info
      t.integer :room_opportunities
      t.string :customer_language_iso
      t.text :booked_rooms
      t.timestamps
    end
    add_index :reservas, :reservation_code
  end
end
