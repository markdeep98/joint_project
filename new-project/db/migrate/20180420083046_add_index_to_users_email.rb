class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
  	#добавдяем index email, в табл users, с разним index
  	add_index :users, :email, unique: true
  end
end
