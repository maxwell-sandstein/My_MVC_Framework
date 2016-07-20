require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_values = params.values

    rows = DBConnection.execute(<<-SQL, *where_values)
        SELECT
          *
        FROM
          #{self.table_name}
        WHERE
          #{self.where_line(params)}
    SQL

    self.parse_all(rows)
  end

  def where_line(params) #make private
    where_line_arr = params.keys.map do |attr|
      "#{attr.to_s} = ?"
    end

    where_line_arr.join(' AND ')
  end

end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
