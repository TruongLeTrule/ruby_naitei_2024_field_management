module ActivitiesHelper
  def create_action user, action, trackable
    NewActivity.create(
      user:,
      action:,
      name: find_name(trackable),
      trackable:,
      trackable_type: trackable.class.name
    )
  end

  def find_name trackable
    return if trackable.instance_of?(::Review)

    trackable.respond_to?(:name) ? trackable.name : trackable&.field&.name
  end

  def activity_action_class action
    case action
    when "create"
      "text-primary"
    when "view"
      "text-blue-500"
    when "update"
      "text-yellow"
    when "destroy"
      "text-red-500"
    else
      "text-gray-500"
    end
  end
end
