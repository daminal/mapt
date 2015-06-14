class CreateZoneCoordinates < ActiveRecord::Migration
  def change
    create_table :zone_coordinates do |t|
      t.references :zone
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :lng, precision: 10, scale: 6

      t.timestamps null: false
    end

    add_index :zone_coordinates, [:lat, :lng]
  end
end
