class Video < ApplicationRecord
  WM_PREFIX = '0wm'
  acts_as_notify :default, methods: [:state_i18n]

  include CheckMachine
  include RailsGrowthEntity
  include RailsInteractLike
  include RailsInteractComment
  attribute :share_count, :integer, default: 0
  attribute :view_count, :integer, default: 0
  attribute :liked_count, :integer, default: 0
  attribute :comments_count, :integer, default: 0
  attribute :state, :string, default: 'draft'

  belongs_to :author, class_name: 'User', optional: true
  belongs_to :video_taxon, optional: true
  has_many :taggeds, as: :tagging, dependent: :delete_all
  has_many :tags, through: :taggeds
  has_many :attitudes, as: :attitudinal, dependent: :delete_all
  has_many :progressions, as: :progressive, dependent: :delete_all

  has_one_attached :media
  has_one_attached :cover

  enum state: {
    draft: 'draft',
    verified: 'verified',
    rejected: 'rejected'
  }

  def do_trigger(params = {})
    self.trigger_to state: params[:state]

    self.class.transaction do
      self.save!
      to_notification(
        receiver: self.author,
        link: url_helpers.admin_videos_url(id: self.id),
        verbose: true
      ) if self.author
    end
  end

  def viewed?(user_id)
    progressions.done.exists?(user_id: user_id)
  end

  def media_url
    media.service_url if media.attachment.present?
  end

  def media_wm_url
    
  end

  def cover_url
    cover.service_url if cover.attachment.present?
  end

  def pre_videos(per = 10)
    self.class.default_where('id-lt': self.id).order(id: :desc).limit(per)
  end

  def next_videos(per = 10)
    self.class.default_where('id-gt': self.id).order(id: :asc).limit(per)
  end

  def share_url
    'http://dappore.store'
  end

  def water_mark
    QiniuHelper.av_watermark(self.media.key, RailsMedia.config.water_mark_url, gravity: 'North', prefix: WM_PREFIX)
  end

end
