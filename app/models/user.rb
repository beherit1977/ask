require 'openssl'

# Модель пользователя.
class User < ActiveRecord::Base
  ITERATIONS = 20_000
  DIGEST = OpenSSL::Digest::SHA256.new

  attr_accessor :password

  has_many :questions

  validates :email, :username, presence: true
  validates :username, :email, uniqueness: true

  validates :email, :email_format => {:message => 'is not looking good'}
  validates :username, length: {in: 2..40}, format: {with: /\A[a-z0-9_]+\z/}

  validates :password, presence: true, on: :create
  validates_confirmation_of :password

  before_validation :username_downcase
  before_save :encrypt_password

  def username_downcase
    self.username.downcase! unless self.username.nil?
  end

  def encrypt_password
    if password.present?
      self.password_salt = User.hash_to_string(OpenSSL::Random.random_bytes(16))

      self.password_hash = User.hash_to_string(
        OpenSSL::PKCS5.pbkdf2_hmac(
          password, password_salt, ITERATIONS, DIGEST.length, DIGEST
        )
      )
    end
  end

  def self.hash_to_string(password_hash)
    password_hash.unpack('H*')[0]
  end

  def self.authenticate(email, password)
    user = find_by(email: email)

    return nil unless user.present?

    hashed_password = User.hash_to_string(
      OpenSSL::PKCS5.pbkdf2_hmac(
        password, user.password_salt, ITERATIONS, DIGEST.length, DIGEST
      )
    )

    return user if user.password_hash == hashed_password

    nil
  end
end
