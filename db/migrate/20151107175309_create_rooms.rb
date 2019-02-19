class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.integer :id_room
      t.integer :reserva_id
      t.integer :occupancy
      t.integer :status

      t.timestamps
    end
    add_index :rooms, :id_room
    add_index :rooms, :reserva_id
  end
end
