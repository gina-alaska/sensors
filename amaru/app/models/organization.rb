class Organization
  include Mongoid::Document
  before_create :generate_access_token
  
  field :name,          type: String
  field :description,   type: String
  field :access_token,  type: String
  
  has_many :current_users, :class_name => 'User', :inverse_of => :current_org
  has_many :memberships
  accepts_nested_attributes_for :memberships, :current_users
  has_many :groups
  has_many :platforms

  validates_uniqueness_of :name

  def users
    memberships.flat_map(&:user)
  end

  # org.create_user current_user
  def add_user(user)
    unless users.include?(user)
      memberships.create!(user: user)
    end
  end

  def admins
    memberships.where(admin: true).flat_map(&:user)
  end
  
  def admin?(user)
    admins.include?(user)
  end
  
  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.where(access_token: access_token).exists?
  end
end