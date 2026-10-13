# Rails jbuilder view template
json.extract! @post, :id, :title, :content, :created_at

json.author do
  json.extract! @post.author, :id, :name, :email
end

json.comments @post.comments do |comment|
  json.extract! comment, :id, :body, :created_at
  json.author comment.user.name
end

json.partial! 'shared/metadata', post: @post

json.cache! [@post, 'v1'] do
  json.view_count @post.view_count
  json.like_count @post.likes.count
end
