class User < ApplicationRecord
	has_many :microposts, dependent: :destroy 
						 #удаление сообщений при удалении пользователей
  	has_many :active_relationships,  class_name:  "Relationship", #подписки
                                   	 foreign_key: "follower_id",
                                     dependent:   :destroy
  	has_many :passive_relationships, class_name:  "Relationship", #подпищики
                                     foreign_key: "followed_id",
                                     dependent:   :destroy

    has_many :following, through: :active_relationships,  source: :followed
    has_many :followers, through: :passive_relationships, source: :follower

	attr_accessor :remember_token, :activation_token
	#перед сохранением в бд, self(текущий пользователь) = email нижний решистр
	before_save   :downcase_email
	before_create :create_activation_digest

	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 }, 
									  format: { with: VALID_EMAIL_REGEX },
									  uniqueness: { case_sensitive: false }

	has_secure_password
	validates :password, presence: true, length: { minimum: 6 },allow_nil: true

	# Возвращает дайджест данной строки.
	def User.digest(string)
	  cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
	                                                BCrypt::Engine.cost
	  BCrypt::Password.create(string, cost: cost)
	end

	# Возвращает случайный токен
	def User.new_token
		SecureRandom.urlsafe_base64
	end

	# Запоминает пользователя в базе данных для использования в постоянной сессии.
  	def remember
    	self.remember_token = User.new_token
    	update_attribute(:remember_digest, User.digest(remember_token))
  	end

	# Возвращает true, если предоставленный токен совпадает с дайджестом.
	def authenticated?(remember_token)
	  return false if remember_digest.nil?
	  BCrypt::Password.new(remember_digest).is_password?(remember_token)
	end

	# Забывает пользователя
	def forget
	  update_attribute(:remember_digest, nil)
	end

  	def feed
    	Micropost.where("user_id = ?", id)
  	end

	# Начать читать сообщения пользователя.
	def follow(other_user)
	  active_relationships.create(followed_id: other_user.id)
	end

	# Перестать читать сообщения пользователя.
	def unfollow(other_user)
	  active_relationships.find_by(followed_id: other_user.id).destroy
	end

	# Возвращает true, если текущий пользователь читает сообщения другого пользователя.
	def following?(other_user)
	  following.include?(other_user)
	end


	private

		# Переводит адрес электронной почты в нижний регистр.
	    def downcase_email
	      self.email = email.downcase
	    end

	    # Создает и присваивает активационнй токен и дайджест.
	    def create_activation_digest
	      self.activation_token  = User.new_token
	      self.activation_digest = User.digest(activation_token)
	    end
end