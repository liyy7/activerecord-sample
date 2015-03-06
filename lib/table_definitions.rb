# encoding: UTF-8

class OfferType
  OFFER_TYPES = %w(
    fulltime
    contract
    parttime
    temporary
    other
  )

  def bit
    1 << OFFER_TYPES.index(offer_type)
  end
end

class Feature
  TITLES = %w(
    childsupport
    dailypayment
    homemaker
    noexperience
    nooverwork
    restonweekend
    shortterm
    student
  )

  def bit
    1 << TITLES.index(title)
  end
end

class JobPosting
  # TODO: for test
  self.table_name = 'job_posting_new'

  has_many :offer_types, class_name: OfferType
  has_many :features, class_name: Feature

  def built_offer_type_bit
    offer_types.map(&:bit).inject { |m, o| m | o }
  end

  def built_feature_bit
    features.map(&:bit).inject { |m, o| m | o }
  end

  def update_bit_coloumns_by_records(records)
    field_name = records.first.class.table_name

    send("#{field_name}s=", records)
    bit = send("built_#{field_name}_bit")

    JobPosting.where(id: id).update_all "#{field_name}_bit = #{field_name}_bit | #{bit}"
  end

  def update_bit_coloumns(attrs)
    bit_attrs = attrs
    .select { |k, v| v.is_a? Integer }
    .map { |k, v| [k, [v].pack('c*')] }
    .to_h

    bit_attrs.empty? || update(bit_attrs)
  end

  def empty_bit_coloumn?(coloum)
    !attributes[coloum.to_s].bytes.any? { |b| b > 0 }
  end
end
