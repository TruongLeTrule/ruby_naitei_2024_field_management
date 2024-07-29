module UsersHelper
  def admin? user
    user.admin?
  end

  def admin
    @admin = User.find_by admin: true
  end
end
