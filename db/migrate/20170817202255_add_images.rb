class AddImages < ActiveRecord::Migration[4.2]
  def change
    create_table :mosaico_images do |t|
      t.string  :file,      null: false
      t.integer :width,     null: false
      t.integer :height,    null: false
      t.integer :filesize,  null: false
      t.string  :mime_type, null: false
      t.string  :type,      null: false
      t.integer :parent_id
      t.timestamps
    end
  end
end
