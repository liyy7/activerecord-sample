# encoding: UTF-8

# Add :invalid_ids as a valid association option
ActiveRecord::Associations::Builder::Association.valid_options << :invalid_ids

module BelongsToReflectionPatch
  def self.included(klass)
    klass.reflect_on_all_associations(:belongs_to).each do |reflection|
      invalid_ids = reflection.options[:invalid_ids]
      klass.class_eval do
        define_method(reflection.name) do
          invalid_ids.include?(instance_eval("#{reflection.name}_id")) ? nil : super()
        end
      end if invalid_ids.is_a?(Array) && !invalid_ids.empty?
    end
  end
end
