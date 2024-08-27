class OrderExportJob
  include Sidekiq::Job
  include Sidekiq::Status::Worker
  include ApplicationHelper
  require "caxlsx"

  def perform orders_for_excel
    total orders_for_excel.size
    p = Axlsx::Package.new
    wb = p.workbook
    wb.add_worksheet(name: "Orders") do |sheet|
      header_style = wb.styles.add_style(
        b: true,
        border: {style: :thin, color: "000000"},
        alignment: {horizontal: :center}
      )

      data_style = wb.styles.add_style(
        border: {style: :thin, color: "000000"},
        alignment: {horizontal: :center}
      )

      add_header(sheet, header_style)

      add_data(sheet, orders_for_excel, data_style)
    end

    file_name = jid ? "orders_#{jid}.xlsx" : "orders.xlsx"
    p.serialize Rails.root.join("public", "data", file_name)
  end

  private

  def add_header sheet, header_style
    sheet.add_row [
      I18n.t("orders.table.user"),
      I18n.t("orders.table.field"),
      I18n.t("orders.table.date"),
      I18n.t("orders.table.started_time"),
      I18n.t("orders.table.finished_time"),
      I18n.t("orders.table.price"),
      I18n.t("orders.table.status"),
      I18n.t("orders.table.created_at"),
      I18n.t("orders.table.updated_at")
    ], style: header_style
  end

  def add_data sheet, orders, data_style
    orders.each.with_index(1) do |order, idx|
      sheet.add_row [
        find_user_name(order),
        find_field_name(order),
        format_date(order["date"]),
        format_time(order["started_time"]),
        format_time(order["finished_time"]),
        order["final_price"],
        translate_status(order["status"]),
        format_date_time(order["created_at"]),
        format_date_time(order["updated_at"])
      ], style: data_style
      at idx
    end
  end

  def format_date date
    Time.zone.parse(date).strftime(Settings.date_format)
  end

  def format_time time
    Time.zone.parse(time).strftime(Settings.time_format)
  end

  def format_date_time date_time
    Time.zone.parse(date_time).strftime(Settings.date_time_format)
  end

  def translate_status status
    I18n.t("activerecord.attributes.order_field.status.#{status}")
  end

  def find_user_name order
    order["user"]["name"]
  end

  def find_field_name order
    order["field"]["name"]
  end
end
