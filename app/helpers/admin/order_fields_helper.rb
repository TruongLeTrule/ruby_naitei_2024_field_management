module Admin::OrderFieldsHelper
  def field_type_options
    FieldType.pluck :name, :id
  end

  def field_options
    Field.pluck :name, :id
  end

  def group_by_options
    [
      [t("admin.order_fields.stats.day").camelize, "day"],
      [t("admin.order_fields.stats.week").camelize, "week"],
      [t("admin.order_fields.stats.month").camelize, "month"]
    ]
  end

  def resolve_group_by group_by
    case group_by&.to_sym
    when :week
      t("admin.order_fields.stats.week")
    when :month
      t("admin.order_fields.stats.month")
    else
      t("admin.order_fields.stats.day")
    end
  end

  def resolve_chart_title group_by, field_type_id, field_id
    base_title = t("admin.order_fields.stats.revenue_chart")
    group_by = resolve_group_by group_by
    field_type = FieldType.find_by(id: field_type_id)&.name ||
                 t("admin.order_fields.stats.all_field_types")
    field = Field.find_by(id: field_id)&.name

    "#{base_title} " \
    "#{t('admin.order_fields.stats.group_by')} #{group_by} " \
    "#{t('admin.order_fields.stats.of')} #{field || field_type}"
  end
end
