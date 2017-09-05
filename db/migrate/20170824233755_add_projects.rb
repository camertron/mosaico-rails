class AddProjects < ActiveRecord::Migration[4.2]
  def change
    create_table :mosaico_projects do |t|
      t.text :html
      t.text :content
      t.text :metadata
      t.string :template_name
      t.timestamps
    end
  end
end
