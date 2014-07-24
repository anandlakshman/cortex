class VideoPost < Post
  index_name     [Rails.env, 'posts'].join('_')
  document_type  'post'

  validates :copyright_owner, presence: true, length: { minimum: 1, maximum: 255 }
  validates :short_description, presence: true, length: { minimum: 25, maximum: 255 }
  validates :tag_list, :seo_title, :seo_description, length: { maximum: 255 }

  # TODO: Figure out a way to get this properly abstracted
  enum display: [:large, :medium, :small]
end