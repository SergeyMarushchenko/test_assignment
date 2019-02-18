# Request using Sequel ORM aimed to extract data from DB in shape suitable for presentation on UI

using Sequel::CoreRefinements

module DbHelpers
  def booking_references_dataset
    DB[:order_positions]
      .select(
        :order_id,
        :name,
        :value,
        Sequel.join([:order_positions[:name], ': ', :order_positions[:value]]).as(:name_value)
      )
      .from_self
      .select do
        [
          order_id,
          array_agg(name_value).as(:name_values),
          hstore(array_agg(name), array_agg(value)).as(:pos_hstore)
        ]
      end
      .group(:order_id)
  end
end


# Storing some model attributes in jsonb column provides
# flexibility in object-relational mapping.
# The Sequel plugin below creates accessor methods
# for such attributes which are expected to be stored in 'jsonb_attributes'
# column of the corresponding table.

module Sequel
  module Plugins::JsonbAttributes
    def self.configure(model, opts = {})
      attributes = opts[:attributes]

      model.class_eval do
        attributes.each do |name|
          attr = name.to_s

          define_method(attr) do
            jsonb_attributes && jsonb_attributes[attr]
          end

          define_method("#{attr}=") do |value|
            attrs = jsonb_attributes || {}
            self.jsonb_attributes = attrs.merge(attr => value)
          end

          define_method("#{attr}?") do
            jsonb_attributes && !!jsonb_attributes[attr]
          end
        end
      end
    end
  end
end


# And this is just for fun =)

module M
  def self.bogosort(array)
    return array if array.length < 2

    loop do
      break if array.each_cons(2).all?{ |left, right| left <= right }

      array.shuffle!
    end

    array
  end
end
