module Admin::FieldsHelper
  def field_header_keys
    %i(# name field_type_id default_price open_time close_time
       booking_count rating revenue created_at action)
  end

  def field_render_keys
    %i(name display_type display_price display_open_time
       display_close_time booking_count display_rating
       revenue display_created_at action)
  end

  def handle_render_fields fields
    fields.map do |field|
      format_field_time field
      format_field_date_time field
      get_field_type_name field
      resolve_field_action_to_html field
      field.display_price = exchange_money field.default_price
      field.revenue = exchange_money field.order_relationships.sum(:final_price)
      field.display_rating = "#{field.average_rating} / #{Settings.max_ratings}"
      field.booking_count = field.order_relationships.count
      field
    end
  end

  def field_type_options
    FieldType.pluck :name, :id
  end

  def first_field_type
    FieldType.first
  end

  def format_input_time time
    return if time.blank?

    Time.zone.parse(time).strftime Settings.time_format
  end

  def rating_options
    (1..Settings.max_ratings).to_a
  end

  private

  def format_field_time field
    field.display_open_time = field.open_time.strftime Settings.time_format
    field.display_close_time = field.close_time.strftime Settings.time_format
  end

  def format_field_date_time field
    field.display_created_at = field.created_at.strftime Settings.date_format
  end

  def resolve_field_action_to_html field
    field.action = link_to t("admin.fields.index.view"),
                           edit_admin_field_path(field),
                           class: "hover:underline text-blue-600"
  end

  def get_field_type_name field
    field.display_type = field.field_type.name
  end
end
