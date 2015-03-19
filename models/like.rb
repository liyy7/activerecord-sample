# encoding: UTF-8

class Like
  belongs_to :job_posting
  belongs_to :user

  self.inheritance_column = :_type_disabled

  TYPES = {
    1 => :LIKE,
    2 => :DISLIKE
  }

  def type
    TYPES[attributes['type']]
  end

  def like?
    type == :LIKE
  end

  def dislike?
    type == :DISLIKE
  end
end
