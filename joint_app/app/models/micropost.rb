class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) } #меняет хронологию сообщений
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 300}
  validate  :picture_size

   private

    # Проводит валидацию размера загруженного изображения.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end

end
