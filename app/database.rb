# frozen_string_literal: true

class Database
  PATH = 'db/scores.yml'

  class << self
    def save(new_data)
      data = load << stringify(new_data)

      File.write(PATH, data.to_yaml)
    end

    def load
      return [] unless File.exist?(PATH)

      yaml = File.read(PATH)
      data = Psych.safe_load(yaml, [Symbol])

      sort_data data
    end

    private

    def stringify(data)
      data.transform_values! { |value| value[1].is_a?(Symbol) ? value : value.to_s }
    end

    def sort_data(data)
      data.sort_by { |value| [-value[:difficulty][0], value[:tries_used], value[:hints_used]] }
    end
  end
end
