class Field < ApplicationRecord
  CREATE_ATTRIBUTES = %i(field_type_id name default_price open_time
close_time description image).freeze

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
  validates :name, uniqueness: {scope: :field_type_id}
  validates :image, content_type: {in: Settings.image_format.split(","),
                                   message: I18n.t(
                                     "fields.errors.invalid_img_format"
                                   )},
                    size:          {less_than: Settings.max_img_size.megabytes,
                                    message: I18n.t(
                                      "fields.errors.too_large_img_size"
                                    )}
  validate :validate_time

  scope :name_like, lambda {|name|
                      where("name LIKE ?", "%#{name}%") if name.present?
                    }
  scope :order_by, lambda {|attribute, direction|
                     order((attribute || :created_at) => (direction || :asc))
                   }
  scope :most_rated, (lambda do
    left_outer_joins(:ratings)
      .group(:id)
      .order("AVG(ratings.rating) DESC")
      .includes(image_attachment: :blob)
  end)
  scope :field_type, lambda {|field_type_id|
                       where(field_type_id:) if field_type_id.present?
                     }
  scope :favourite_by_current_user, ->(ids){where id: ids if ids.present?}

  def average_rating
    ratings.average(:rating).to_f
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
