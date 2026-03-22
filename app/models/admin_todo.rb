class AdminTodo < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  scope :pending, -> { where(done: false) }
  scope :completed, -> { where(done: true) }
  scope :recent, -> { order(done: :asc, created_at: :desc) }

  def mark_as_done!
    update(done: true)
  end

  def mark_as_pending!
    update(done: false)
  end
end
