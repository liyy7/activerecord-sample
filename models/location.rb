# encoding: UTF-8

require 'patchs/belongs_to_reflection_patch'

class Location
  belongs_to :job_posting
  belongs_to :country, { invalid_ids: [0] }
  belongs_to :administrative_area, { invalid_ids: [0] }
  belongs_to :locality_group, { invalid_ids: [0] }
  belongs_to :locality, { invalid_ids: [0] }
  belongs_to :ward, { invalid_ids: [0] }
end

Location.include BelongsToReflectionPatch
