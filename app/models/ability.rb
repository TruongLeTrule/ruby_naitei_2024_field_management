class Ability
  include CanCan::Ability

  def initialize user
    can :read, Field
    return unless user

    user_authorization user
    return unless user.admin?

    can :manage, :all
  end

  private

  def user_authorization user
    can [:read, :update], User, user_id: user.id
    can [:read, :update], OrderField, user_id: user.id
    can :create, OrderField
    can :read, PublicActivity::Activity, owner_id: user.id, owner_type: "User"
    can [:create, :update, :destroy], Rating, user_id: user.id
    can [:create, :update, :destroy], Review, user_id: user.id
    can [:apply], Voucher, user_id: user.id
  end
end
