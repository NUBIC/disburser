class CreateLoginAudits < ActiveRecord::Migration[5.0]
  def change
    create_table :login_audits do |t|
      t.integer    :user_id,     null: false
      t.timestamps
    end
  end
end

