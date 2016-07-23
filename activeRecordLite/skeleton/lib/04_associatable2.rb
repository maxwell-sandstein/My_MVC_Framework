require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      closest_relationship_pk = through_options.primary_key
      closest_relationship_fk = through_options.foreign_key
      neighbor_table = through_options.table_name

      next_over_relationship_pk = source_options.primary_key
      next_over_relationship_fk = source_options.foreign_key
      second_order_neighbor_table = source_options.table_name

      key_value_to_join_on = self.send(closest_relationship_fk)

      results = DBConnection.execute(<<-SQL, key_value_to_join_on)
           SELECT
             #{second_order_neighbor_table}.*
           FROM
             #{second_order_neighbor_table}
           JOIN
             #{neighbor_table}
           ON
             #{neighbor_table}.#{next_over_relationship_fk} = #{second_order_neighbor_table}.#{next_over_relationship_pk}
           WHERE
             #{neighbor_table}.#{closest_relationship_pk} = ?
      SQL

      source_options.model_class.new(results[0])
    end



  end

end
