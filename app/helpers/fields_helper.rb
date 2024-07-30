module FieldsHelper
  def get_am_start_time started_time
    started_time.hour + started_time.min / 60.0
  end

  def get_am_end_time finished_time
    if finished_time.hour < 12
      finished_time.hour + finished_time.min / 60.0
    else
      12
    end
  end

  def get_pm_start_time started_time
    if started_time.hour > 13
      started_time.strftime("%I").to_i + started_time.min / 60.0
    else
      0
    end
  end

  def get_pm_end_time finished_time
    finished_time.strftime("%I").to_i + finished_time.min / 60.0
  end
end
