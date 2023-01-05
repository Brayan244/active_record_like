require_relative 'database'

class ActiveRecord
  def self.inherited(subclass)
    table_name = "#{subclass.to_s.downcase}s"
    columns = subclass.columns

    connection.create_table(table_name, columns)
    define_accessors(columns)
  end

  def self.columns(*column_names)
    @column_names = column_names
  end

  def self.connection
    @connection ||= Database.instance
  end

  def self.define_accessors(columns)
    columns.each do |column|
      define_method(column) do
        instance_variable_get("@#{column}")
      end

      define_method("#{column}=") do |value|
        instance_variable_set("@#{column}", value)
      end
    end
  end
end
