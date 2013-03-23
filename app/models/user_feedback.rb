class UserFeedback < ActiveRecord::Base
  self.table_name = "user_feedback"
  belongs_to :user
  belongs_to :creator, :class_name => "User"
  before_validation :initialize_creator, :on => :create
  attr_accessible :body, :user_id, :category, :user_name
  validates_presence_of :user, :creator, :body, :category
  validate :creator_is_privileged
  validate :user_is_not_creator
  after_create :create_dmail

  module SearchMethods
    def positive
      where("category = ?", "positive")
    end

    def neutral
      where("category = ?", "neutral")
    end

    def negative
      where("category = ?", "negative")
    end

    def for_user(user_id)
      where("user_id = ?", user_id)
    end

    def search(params)
      q = scoped
      return q if params.blank?

      if params[:user_id].present?
        q = q.for_user(params[:user_id].to_i)
      end

      if params[:user_name].present?
        q = q.where("user_id = (select _.id from users _ where lower(_.name) = ?)", params[:user_name].downcase)
      end

      if params[:creator_id].present?
         q = q.where("creator_id = ?", params[:creator_id].to_i)
      end

      if params[:creator_name].present?
        q = q.where("creator_id = (select _.id from users _ where lower(_.name) = ?)", params[:creator_name].downcase)
      end

      q
    end
  end

  extend SearchMethods

  def initialize_creator
    self.creator_id = CurrentUser.id
  end

  def user_name
    User.id_to_name(user_id)
  end

  def creator_name
    User.id_to_name(creator_id)
  end

  def user_name=(name)
    self.user_id = User.name_to_id(name)
  end

  def create_dmail
    body = %{#{creator_name} created a "#{category} record":/user_feedbacks?search[user_id]=#{user_id} for your account. #{body}}
    Dmail.create_split(:to_id => user_id, :title => "Your user record has been updated", :body => body)
  end

  def creator_is_privileged
    if !creator.is_privileged?
      errors[:creator] << "must be privileged"
      return false
    else
      return true
    end
  end
  
  def user_is_not_creator
    if user_id == creator_id
      errors[:creator] << "cannot submit feedback for yourself"
      return false
    else
      return true
    end
  end
end
