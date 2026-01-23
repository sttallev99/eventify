class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :user_name, :created_at

  def user_name
    object.user.first_name + " " + object.user.last_name
  end
end
