class Field < ApplicationRecord
  include UsersHelper
  include PublicActivity::Model
  tracked owner: ->(_controller, _model){User.find_by admin: true}

  CREATE_ATTRIBUTES = %i(field_type_id name default_price open_time
close_time description image).freeze

  attr_accessor :display_type, :display_price, :display_open_time,
                :display_close_time, :display_created_at,
                :display_rating, :action, :revenue, :booking_count

  belongs_to :field_type
  has_many :unavailable_field_schedules, dependent: :destroy
  has_many :favourite_relationships, class_name: FavouriteField.name,
  dependent: :destroy
  has_many :favourite_users, through: :favourite_relationships,
source: :user
  has_many :order_relationships, class_name: OrderField.name,
    dependent: :destroy
  has_many :ordered_users, through: :order_relationships,
source: :user
  has_many :ratings, dependent: :destroy
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [Settings.limit_img_size,
                                                  Settings.limit_img_size]
  end

  validates :field_type_id, :name, :default_price, :open_time, :close_time,
            presence: true
  validates :name, uniqueness: {scope: :field_type_id},
                    length: {maximum: Settings.max_name_length}
  validates :description, length: {maximum: Settings.max_length_255}
  validates :image, content_type: {in: Settings.image_format.split(","),
                                   message: I18n.t(
                                     "fields.errors.invalid_img_format"
                                   )},
                    size: {less_than: Settings.max_img_size.megabytes,
                           message: I18n.t(
                             "fields.errors.too_large_img_size"
                           )}
  validate :validate_time

  scope :name_like, lambda {|name|
                      where("name LIKE ?", "%#{name}%") if name.present?
                    }
  scope :order_by, lambda {|attribute = :created_at, direction = :asc|
                     order(attribute || :created_at => direction || :asc)
                   }
  scope :most_rated, (lambda do |option = false|
    if option
      left_outer_joins(:ratings)
       .group(:id)
       .order("AVG(ratings.rating) DESC")
       .includes(image_attachment: :blob)
    end
  end)
  scope :field_type, lambda {|field_type_id = "all"|
                       if field_type_id != "all" && field_type_id.present?
                         where(field_type_id:)
                       end
                     }
  scope :favourite_by_current_user, lambda {|ids = nil|
                                      ids.present? ? where(id: ids) : none
                                    }

  ransacker :revenue,
            formatter: lambda {|value|
                         value.to_f / I18n.t("number.money.exchange_rate")
                       } do
    Arel.sql("(
      SELECT SUM(order_fields.final_price)
      FROM order_fields
      WHERE order_fields.field_id = fields.id
      GROUP BY fields.id
    )")
  end
  ransacker :rating do
    Arel.sql("(
      SELECT AVG(ratings.rating)
      FROM ratings
      WHERE ratings.field_id = fields.id
      GROUP BY fields.id
    )")
  end
  ransacker :booking_count do
    Arel.sql("(
      SELECT COUNT(order_fields.id)
      FROM order_fields
      WHERE order_fields.field_id = fields.id
      GROUP BY fields.id
    )")
  end

  class << self
    def ransackable_associations _auth_object = nil
      %w(activities favourite_relationships favourite_users
field_type image_attachment image_blob order_relationships ordered_users ratings
unavailable_field_schedules)
    end

    def ransackable_attributes _auth_object = nil
      %w(close_time created_at default_price description
name open_time updated_at field_type_id revenue rating booking_count)
    end
  end

  def average_rating
    ratings.average(:rating).to_f.round(1)
  end

  def has_any_uncompleted_order?
    order_relationships.approved.each do |order|
      return true if order.uncomplete?
    end
    false
  end

  private

  def validate_time
    return if close_time.nil? || open_time.nil? || close_time > open_time

    errors.add :base, I18n.t("fields.errors.valid_time")
  end
end
