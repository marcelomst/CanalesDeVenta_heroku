class CreateSolicituds < ActiveRecord::Migration
  def change
    create_table (:solicituds) do |t|
      t.bigint :id_solicitud
      t.string :lname 
      t.string :fname  
      t.string :email  
      t.string :city 
      t.string :phone  
      t.string :street  
      t.string :country  
      t.string :arrival_hour  
      t.string :notes  
      t.float :amount 
      t.text :rooms
      t.string :dfrom
      t.string :dto
      t.bigint :reservation_code
      t.integer :estado, :null => false, :default => 0
      t.bigint :reservation_code_ota
      t.timestamps
    end
    add_index :solicituds, :id_solicitud
    add_index :solicituds, :reservation_code
    add_index :solicituds, :reservation_code_ota
  end
end
