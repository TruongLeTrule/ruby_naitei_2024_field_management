module UsersHelper
  def admin
    @admin = User.find_by admin: true
  end

  def get_profile_image user
    user.image.attached? ? user.image : "avatar.jpg"
  end
end
