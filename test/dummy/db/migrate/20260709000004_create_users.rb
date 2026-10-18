class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email
      t.string :password_digest
      t.string :api_token

      t.timestamps
    end
  end
end
