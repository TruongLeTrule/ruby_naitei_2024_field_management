module UsersHelper
  def admin
    @admin = User.find_by admin: true
  end
end
