class User
  include Mongoid::Document
  before_create :generate_access_token
  
  field :provider,      type: String
  field :uid,           type: String
  field :name,          type: String
  field :email,         type: String,  default: ''
  field :admin,         type: Boolean, default: false
  field :active,        type: Boolean, default: true
  field :access_token,  type: String
  
  attr_protected :provider, :uid, :name, :email, :admin
  
  validates_uniqueness_of :name
  validates_uniqueness_of :email

  def to_param
    self.name
  end
  
  def guest?
    self.new_record?
  end
  
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
      end      
    end
  end

  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end
end